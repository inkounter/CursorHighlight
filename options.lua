local thisAddonName, namespace = ...

local defaultConfig = {
    ["color"] = {1, 0, 1, 0.6}, -- r, g, b, a
}

local handleEvent = function(frame, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == thisAddonName then
            frame:UnregisterEvent("ADDON_LOADED")

            if _G["CursorHighlightConfig"] == nil then
                _G["CursorHighlightConfig"] = defaultConfig
            end

            local frame = CreateFrame(
                "Frame",
                "CursorHighlightFrame",
                UIParent
            )
            frame:SetSize(32, 32)
            frame:SetPoint("CENTER")

            local texture = frame:CreateTexture(nil, "BACKGROUND")
            texture:SetAllPoints(frame)

            texture:SetTexture("Interface\\AddOns\\CursorHighlight\\Ring_30px")
            local color = _G["CursorHighlightConfig"]["color"]
            texture:SetVertexColor(color[1], color[2], color[3], color[4])

            -- Update the position of the frame every rendered frame.

            frame:SetScript(
                "OnUpdate",
                function(self)
                    local x, y = GetCursorPosition()
                    local scale = UIParent:GetEffectiveScale()

                    self:ClearAllPoints()
                    self:SetPoint(
                        "CENTER",
                        UIParent,
                        "BOTTOMLEFT",
                        x / scale,
                        y / scale)
                end
            )
        end
    end
end

local Options = {
    ["setColor"] = function(info, r, g, b, a)
        _G["CursorHighlightConfig"]["color"] = {r, g, b, a}
    end,

    ["getColor"] = function(info)
        local config = _G["CursorHighlightConfig"]["color"]
        return config[1], config[2], config[3], config[4]
    end,

    ["register"] = function(self)
        local ac = LibStub("AceConfig-3.0")
        local optionsTable = {
            ["name"] = thisAddonName,
            ["type"] = "group",
            ["args"] = {
                ["color"] = {
                    ["type"] = "color",
                    ["name"] = "Texture Color",
                    ["desc"] = "The color of the highlight texture",
                    ["set"] = self.setColor,
                    ["get"] = self.getColor,
                    ["hasAlpha"] = true,
                },
            },
        }
        ac:RegisterOptionsTable(thisAddonName, optionsTable, nil)

        local acd = LibStub("AceConfigDialog-3.0")
        return acd:AddToBlizOptions(thisAddonName)
    end,
}

local optionsFrame, optionsCategoryId = Options:register()

optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript('OnEvent', handleEvent)
