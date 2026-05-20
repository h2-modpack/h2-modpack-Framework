local deps = ...
local lib = deps.lib
local rom = deps.rom
local frameworkPluginGuid = deps.frameworkPluginGuid

local logging = import "logging.lua"
local hashCodec = import "hash_codec.lua"
local createTheme = import("ui/theme.lua", nil, {
    rom = rom,
})
local createModuleRegistry = import("module_registry.lua", nil, {
    lib = lib,
    rom = rom,
    logging = logging,
})
local createHashGroupBuilder = import("hash_group_builder.lua")
local profileTools = import("profiles.lua", nil, {
    hashCodec = hashCodec,
    createHashGroupBuilder = createHashGroupBuilder,
    logging = logging,
})
local createConfigHash = import("config_hash.lua", nil, {
    rom = rom,
    hashCodec = hashCodec,
    createHashGroupBuilder = createHashGroupBuilder,
    logging = logging,
})
local createHud = import("hud.lua")
local createUI = import("ui.lua", nil, {
    rom = rom,
    logging = logging,
})

local bootConstructors = {
    createModuleRegistry = createModuleRegistry,
    createConfigHash = createConfigHash,
    createHud = createHud,
    createUI = createUI,
    createTheme = createTheme,
}

local frameworkRuntime = nil

local function disposePack(pack)
    local packUi = pack and pack.ui
    if not packUi then
        return
    end

    if packUi.dispose ~= nil then
        packUi.dispose()
    elseif packUi.handleHostGuiClosed ~= nil then
        packUi.handleHostGuiClosed()
    end
end

local function ValidateInitArgs(packId, windowTitle, config, numProfiles, defaultProfiles, opts)
    assert(type(packId) == "string" and packId ~= "",
        "Framework.init: packId must be a non-empty string")
    assert(type(windowTitle) == "string" and windowTitle ~= "",
        "Framework.init: windowTitle must be a non-empty string")
    assert(type(config) == "table", "Framework.init: config must be a table")
    assert(type(defaultProfiles) == "table",
        "Framework.init: defaultProfiles must be a table")
    assert(opts == nil or type(opts) == "table",
        "Framework.init: opts must be a table when provided")
    opts = opts or {}
    assert(opts.hideHashMarker == nil or type(opts.hideHashMarker) == "boolean",
        "Framework.init: hideHashMarker must be a boolean when provided")
    assert(opts.moduleOrder == nil or type(opts.moduleOrder) == "table",
        "Framework.init: opts.moduleOrder must be a table when provided")
    assert(opts.drawPackQuickContent == nil or type(opts.drawPackQuickContent) == "function",
        "Framework.init: opts.drawPackQuickContent must be a function when provided")
    assert(type(config.ModEnabled) == "boolean",
        "Framework.init: config.ModEnabled must be a boolean")
    assert(type(config.DebugMode) == "boolean",
        "Framework.init: config.DebugMode must be a boolean")
    assert(type(numProfiles) == "number" and numProfiles > 0 and math.floor(numProfiles) == numProfiles,
        "Framework.init: numProfiles must be a positive integer")

    profileTools.normalizeProfiles(config.Profiles, numProfiles)
    return opts
end

local function ValidateRuntimePrerequisites()
    assert(rom and type(rom.ImGui) == "table",
        "Framework.init: rom.ImGui is not ready; call Framework.init after game load")
    assert(rom.game and type(rom.game.SetupRunData) == "function",
        "Framework.init: rom.game.SetupRunData is not ready; call Framework.init after game load")
    assert(lib and type(lib.createFrameworkRuntime) == "function",
        "Framework.init: adamant-ModpackLib framework runtime is not available")
    assert(type(frameworkPluginGuid) == "string" and frameworkPluginGuid ~= "",
        "Framework.init: frameworkPluginGuid must be a non-empty string")
end

local function ValidateCoordinatorArgs(packId, config, rebuildCallback)
    assert(type(packId) == "string" and packId ~= "",
        "Framework.registerCoordinator: packId must be a non-empty string")
    assert(config == nil or type(config) == "table",
        "Framework.registerCoordinator: config must be a table when provided")
    assert(config == nil or type(config.ModEnabled) == "boolean",
        "Framework.registerCoordinator: config.ModEnabled must be a boolean")
    assert(rebuildCallback == nil or type(rebuildCallback) == "function",
        "Framework.registerCoordinator: rebuildCallback must be a function when provided")
end

local function GetFrameworkRuntime()
    if frameworkRuntime ~= nil then
        return frameworkRuntime
    end

    frameworkRuntime = lib.createFrameworkRuntime(frameworkPluginGuid)
    assert(type(frameworkRuntime) == "table"
        and type(frameworkRuntime.diagnostics) == "table"
        and type(frameworkRuntime.diagnostics.isLibDebugEnabled) == "function"
        and type(frameworkRuntime.diagnostics.setLibDebugEnabled) == "function"
        and type(frameworkRuntime.coordinator) == "table"
        and type(frameworkRuntime.coordinator.register) == "function"
        and type(frameworkRuntime.coordinator.registerRebuild) == "function"
        and type(frameworkRuntime.coordinator.isRegistered) == "function"
        and type(frameworkRuntime.modules) == "table"
        and type(frameworkRuntime.modules.getLiveHost) == "function"
        and type(frameworkRuntime.overlays) == "table"
        and type(frameworkRuntime.overlays.order) == "table"
        and type(frameworkRuntime.overlays.define) == "function"
        and type(frameworkRuntime.ui) == "table"
        and type(frameworkRuntime.ui.suppressOverlays) == "function"
        and type(frameworkRuntime.ui.areOverlaysSuppressed) == "function"
        and type(frameworkRuntime.hashing) == "table"
        and type(frameworkRuntime.hashing.getRoots) == "function"
        and type(frameworkRuntime.hashing.getAliases) == "function"
        and type(frameworkRuntime.hashing.valuesEqual) == "function"
        and type(frameworkRuntime.hashing.getPackWidth) == "function"
        and type(frameworkRuntime.hashing.toHash) == "function"
        and type(frameworkRuntime.hashing.fromHash) == "function"
        and type(frameworkRuntime.hashing.isHashTokenValid) == "function"
        and type(frameworkRuntime.hashing.readPackedBits) == "function"
        and type(frameworkRuntime.hashing.writePackedBits) == "function",
        "Framework.init: adamant-ModpackLib framework runtime is not available")
    return frameworkRuntime
end

local function registerCoordinator(packId, config, rebuildCallback)
    ValidateCoordinatorArgs(packId, config, rebuildCallback)
    local runtime = GetFrameworkRuntime()
    runtime.coordinator.register(packId, config)
    runtime.coordinator.registerRebuild(packId, rebuildCallback)
    return true
end

local function init(packId, windowTitle, config, numProfiles, defaultProfiles, opts)
    opts = ValidateInitArgs(packId, windowTitle, config, numProfiles, defaultProfiles, opts)
    ValidateRuntimePrerequisites()

    local runtime = GetFrameworkRuntime()
    assert(runtime.coordinator.isRegistered(packId),
        "Framework.init: coordinator must register before init; see Core/main.lua")

    local existingPack = FrameworkPackRegistry.packs[packId]
    local packIndex = existingPack and existingPack._index or #FrameworkPackRegistry.packList + 1

    local moduleRegistry = bootConstructors.createModuleRegistry(packId, config, runtime)
    local configHash = bootConstructors.createConfigHash(moduleRegistry, config, packId, runtime.hashing)
    local theme = bootConstructors.createTheme()
    local auditSavedProfiles = function(auditPackId, profileSlots, auditModuleRegistry)
        return profileTools.auditSavedProfiles(auditPackId, profileSlots, auditModuleRegistry, runtime.hashing)
    end

    moduleRegistry.refresh(opts.moduleOrder)

    local hud = bootConstructors.createHud(packId, packIndex, configHash, theme, config,
        opts.hideHashMarker == true, runtime)
    local ui = bootConstructors.createUI(moduleRegistry, hud, theme, config, packId, windowTitle,
        numProfiles, defaultProfiles, opts.drawPackQuickContent, auditSavedProfiles, runtime)

    auditSavedProfiles(packId, config.Profiles, moduleRegistry)

    local pack = {
        moduleRegistry = moduleRegistry,
        configHash = configHash,
        hud = hud,
        ui = ui,
        _index = packIndex,
    }

    disposePack(existingPack)

    if not existingPack then
        table.insert(FrameworkPackRegistry.packList, packId)
    end
    FrameworkPackRegistry.packs[packId] = pack

    if config.ModEnabled then
        hud.setModMarker(true)
    end

    return pack
end

local function tryInit(packId, windowTitle, config, numProfiles, defaultProfiles, opts)
    local ok, pack = xpcall(function()
        return init(packId, windowTitle, config, numProfiles, defaultProfiles, opts)
    end, debug.traceback)

    if ok then
        return true, pack, nil
    end

    local err = tostring(pack)
    local logPackId = type(packId) == "string" and packId ~= "" and packId or "framework"
    logging.warn(logPackId, "Framework init failed; skipping pack: %s", err)
    return false, nil, err
end

local function createGuiCallbacks(packId)
    assert(type(packId) == "string" and packId ~= "",
        "Framework.createGuiCallbacks: packId must be a non-empty string")

    local wasGuiOpen = rom.gui.is_open() == true

    local function render()
        local pack = FrameworkPackRegistry.packs[packId]
        if not pack or not pack.ui then
            return
        end
        pack.ui.renderWindow()
    end

    local function alwaysDraw()
        local isGuiOpen = rom.gui.is_open() == true

        if wasGuiOpen and not isGuiOpen then
            local pack = FrameworkPackRegistry.packs[packId]
            if pack and pack.ui then
                pack.ui.handleHostGuiClosed()
            end
        end

        wasGuiOpen = isGuiOpen
    end

    local function menuBar()
        local pack = FrameworkPackRegistry.packs[packId]
        if not pack or not pack.ui then
            return
        end
        pack.ui.addMenuBar()
    end

    return {
        render = render,
        alwaysDraw = alwaysDraw,
        menuBar = menuBar,
    }
end

return {
    registerCoordinator = registerCoordinator,
    init = init,
    tryInit = tryInit,
    createGuiCallbacks = createGuiCallbacks,
}
