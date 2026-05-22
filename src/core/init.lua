local deps = ...
local lib = deps.lib
local rom = deps.rom
local frameworkPluginGuid = deps.frameworkPluginGuid

local logging = import "core/logging.lua"
local hashCodec = import "core/hash/codec.lua"
local createTheme = import("core/ui/theme.lua", nil, {
    rom = rom,
})
local createModuleRegistry = import("core/modules/registry.lua", nil, {
    lib = lib,
    rom = rom,
    logging = logging,
})
local createHashGroupBuilder = import("core/hash/group_builder.lua")
local profileTools = import("core/profiles/audit.lua", nil, {
    hashCodec = hashCodec,
    createHashGroupBuilder = createHashGroupBuilder,
    logging = logging,
})
local createConfigHash = import("core/hash/config_hash.lua", nil, {
    rom = rom,
    hashCodec = hashCodec,
    createHashGroupBuilder = createHashGroupBuilder,
    logging = logging,
})
local createHud = import("core/hud/runtime.lua")
local createUI = import("core/ui/window.lua", nil, {
    rom = rom,
    logging = logging,
})

local constructors = {
    createModuleRegistry = createModuleRegistry,
    createConfigHash = createConfigHash,
    createHud = createHud,
    createUI = createUI,
    createTheme = createTheme,
}

local frameworkRuntime = nil

local function getFrameworkRuntime()
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
        "Framework.createPack: adamant-ModpackLib framework runtime is not available")
    return frameworkRuntime
end

return import("core/pack_bootstrap.lua", nil, {
    rom = rom,
    lib = lib,
    logging = logging,
    profileTools = profileTools,
    constructors = constructors,
    frameworkPluginGuid = frameworkPluginGuid,
    getFrameworkRuntime = getFrameworkRuntime,
})
