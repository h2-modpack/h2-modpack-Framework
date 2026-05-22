local deps = ...
local rom = deps.rom
local frameworkRuntime = deps.frameworkRuntime

local logging = import "core/logging.lua"
local hashCodec = import "core/hash/codec.lua"
local createTheme = import("core/ui/theme.lua", nil, {
    rom = rom,
})
local createModuleRegistry = import("core/modules/registry.lua", nil, {
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

return import("core/pack_bootstrap.lua", nil, {
    rom = rom,
    logging = logging,
    profileTools = profileTools,
    constructors = constructors,
    frameworkRuntime = frameworkRuntime,
})
