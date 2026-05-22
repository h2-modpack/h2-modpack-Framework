local ctx = ...

local rom = ctx.rom
local ui = rom.ImGui
local drawPackQuickContent = ctx.drawPackQuickContent
local profiles = ctx.profiles
local staging = ctx.staging
local runtime = ctx.runtime
local snapshotAccess = ctx.snapshotAccess
local colors = ctx.colors
local theme = ctx.theme

local function TextColored(imgui, color, text)
    imgui.TextColored(color[1], color[2], color[3], color[4], text)
end

local packQuickContentContext = {
    ui = ui,
    colors = colors,
    theme = theme,
    getModulesStatus = runtime.getModulesStatus,
    setModulesEnabled = function(moduleIds, enabled)
        return runtime.setModulesEnabled(moduleIds, enabled, snapshotAccess.get())
    end,
}

local function draw(quickList, snapshot)
    profiles.drawQuickSelector()

    ui.Separator()
    ui.Spacing()

    if type(drawPackQuickContent) == "function" then
        drawPackQuickContent(packQuickContentContext)
    end

    for _, entry in ipairs(quickList or {}) do
        if staging.modules[entry.id] then
            local host = snapshotAccess.getHost(entry, snapshot)
            if not host then
                goto continue
            end

            ui.Separator()
            ui.Spacing()
            TextColored(ui, colors.info, entry.name or entry.id)
            ui.Spacing()
            host.drawQuickContent()
            runtime.commitEntrySession(entry, snapshot)
        end
        ::continue::
    end
end

return draw
