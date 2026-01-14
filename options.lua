local thisAddonName, namespace = ...

local defaultConfig = {
    ["color"] = {1, 0, 1, 0.6}, -- r, g, b, a
    ["size"] = 32,
    ["blend"] = "ADD",
    ["texture"] = "Interface\\AddOns\\CursorHighlight\\Ring_30px",
}

local highlightFrame = nil

local Options = {
    ["setColor"] = function(self, info, r, g, b, a)
        _G["CursorHighlightConfig"]["color"] = {r, g, b, a}
        self:redrawHighlight()
    end,

    ["getColor"] = function(self, info)
        local config = _G["CursorHighlightConfig"]["color"]
        return config[1], config[2], config[3], config[4]
    end,

    ["setSize"] = function(self, info, value)
        _G["CursorHighlightConfig"]["size"] = value
        self:redrawHighlight()
    end,

    ["getSize"] = function(self, info)
        return _G["CursorHighlightConfig"]["size"]
    end,

    ["setBlend"] = function(self, info, value)
        _G["CursorHighlightConfig"]["blend"] = value
        self:redrawHighlight()
    end,

    ["getBlend"] = function(self, info)
        return _G["CursorHighlightConfig"]["blend"]
    end,

    ["setTexture"] = function(self, info, value)
        _G["CursorHighlightConfig"]["texture"] = value
        self:redrawHighlight()
    end,

    ["getTexture"] = function(self, info)
        return _G["CursorHighlightConfig"]["texture"]
    end,

    ["defaultOptions"] = function(self)
        -- Copy the color attributes.

        _G["CursorHighlightConfig"]["color"] = {}
        for _, value in ipairs(defaultConfig["color"]) do
            table.insert(_G["CursorHighlightConfig"]["color"], value)
        end

        for _, key in ipairs({"size", "blend", "texture"}) do
            _G["CursorHighlightConfig"][key] = defaultConfig[key]
        end

        self:redrawHighlight()
    end,

    ["redrawHighlight"] = function(self)
        local config = _G["CursorHighlightConfig"]
        highlightFrame:SetSize(config["size"], config["size"])
        highlightFrame.texture:SetTexture(config["texture"])
        highlightFrame.texture:SetVertexColor(
            config["color"][1],
            config["color"][2],
            config["color"][3],
            config["color"][4]
        )
        highlightFrame.texture:SetBlendMode(config["blend"])
    end,

    ["register"] = function(self)
        local ac = LibStub("AceConfig-3.0")
        local optionsTable = {
            ["name"] = thisAddonName,
            ["type"] = "group",
            ["args"] = {
                ["color"] = {
                    ["type"] = "color",
                    ["name"] = "Color",
                    ["order"] = 1,
                    ["set"] = function(...) return self:setColor(...) end,
                    ["get"] = function(...) return self:getColor(...) end,
                    ["hasAlpha"] = true,
                },

                ["size"] = {
                    ["type"] = "range",
                    ["name"] = "Size",
                    ["order"] = 2,
                    ["min"] = 1,
                    ["max"] = 9999,
                    ["softMin"] = 1,
                    ["softMax"] = 200,
                    ["step"] = 1,
                    ["set"] = function(...) return self:setSize(...) end,
                    ["get"] = function(...) return self:getSize(...) end,
                },

                ["blend"] = {
                    ["type"] = "select",
                    ["name"] = "Blend Mode",
                    ["order"] = 3,
                    ["values"] = {
                        ["BLEND"] = "Opaque",
                        ["ADD"] = "Glow",
                    },
                    ["set"] = function(...) return self:setBlend(...) end,
                    ["get"] = function(...) return self:getBlend(...) end,
                },

                ["texture"] = {
                    ["type"] = "input",
                    ["name"] = "Texture Path",
                    ["order"] = 4,
                    ["width"] = "full",
                    ["set"] = function(...) return self:setTexture(...) end,
                    ["get"] = function(...) return self:getTexture(...) end,
                },

                ["resetDefault"] = {
                    ["type"] = "execute",
                    ["name"] = "Reset to Defaults",
                    ["order"] = 5,
                    ["func"] = function(...) return self:defaultOptions(...) end,
                }
            },
        }
        ac:RegisterOptionsTable(thisAddonName, optionsTable, nil)

        local acd = LibStub("AceConfigDialog-3.0")
        return acd:AddToBlizOptions(thisAddonName)
    end,
}

local handleAddonLoaded = function(frame, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == thisAddonName then
            frame:UnregisterEvent("ADDON_LOADED")

            if _G["CursorHighlightConfig"] == nil then
                _G["CursorHighlightConfig"] = defaultConfig
            end

            -- Create the frame and texture.

            highlightFrame = CreateFrame(
                "Frame",
                "CursorHighlightFrame",
                UIParent
            )
            highlightFrame:SetPoint("CENTER")

            highlightFrame.texture = highlightFrame:CreateTexture(
                nil,
                "BACKGROUND"
            )
            highlightFrame.texture:SetAllPoints(highlightFrame)

            -- Update the position of the frame every rendered frame.

            highlightFrame:SetScript(
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

            -- Fill out the other properties.

            Options:redrawHighlight()
        end
    end
end

local optionsFrame, optionsCategoryId = Options:register()

optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript("OnEvent", handleAddonLoaded)
