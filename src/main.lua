local mods = rom.mods
mods["SGG_Modding-ENVY"].auto()

---@module "adamant-ModpackLib"
---@type AdamantModpackLib
local lib = mods["adamant-ModpackLib"]
FrameworkPackRegistry = FrameworkPackRegistry or {}

FrameworkPackRegistry.packs = FrameworkPackRegistry.packs or {}
FrameworkPackRegistry.packList = FrameworkPackRegistry.packList or {}

local packInit = import("pack_init.lua", nil, {
    lib = lib,
    rom = rom,
})

public.init = packInit.init
public.tryInit = packInit.tryInit
public.createGuiCallbacks = packInit.createGuiCallbacks
