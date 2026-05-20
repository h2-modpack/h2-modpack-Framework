local mods = rom.mods
mods["SGG_Modding-ENVY"].auto()

---@module "adamant-ModpackLib"
---@type AdamantModpackLib
local lib = mods["adamant-ModpackLib"]
local FRAMEWORK_PLUGIN_GUID = _PLUGIN.guid
FrameworkPackRegistry = FrameworkPackRegistry or {}

FrameworkPackRegistry.packs = FrameworkPackRegistry.packs or {}
FrameworkPackRegistry.packList = FrameworkPackRegistry.packList or {}

local packInit = import("pack_init.lua", nil, {
    lib = lib,
    rom = rom,
    frameworkPluginGuid = FRAMEWORK_PLUGIN_GUID,
})

public.init = packInit.init
public.tryInit = packInit.tryInit
public.registerCoordinator = packInit.registerCoordinator
public.createGuiCallbacks = packInit.createGuiCallbacks
