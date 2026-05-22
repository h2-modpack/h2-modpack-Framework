local mods = rom.mods
mods["SGG_Modding-ENVY"].auto()

---@module "adamant-ModpackLib"
---@type AdamantModpackLib
local lib = mods["adamant-ModpackLib"]
assert(lib and type(lib.createFrameworkRuntime) == "function",
    "adamant-ModpackFramework: adamant-ModpackLib framework runtime is not available")
local frameworkRuntime = lib.createFrameworkRuntime(_PLUGIN.guid)
FrameworkPackRegistry = FrameworkPackRegistry or {}

FrameworkPackRegistry.packs = FrameworkPackRegistry.packs or {}
FrameworkPackRegistry.packList = FrameworkPackRegistry.packList or {}

local core = import("core/init.lua", nil, {
    rom = rom,
    frameworkRuntime = frameworkRuntime,
})

public.createPack = core.createPack
public.registerCoordinator = core.registerCoordinator
public.createGuiCallbacks = core.createGuiCallbacks
