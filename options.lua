local thisAddonName, namespace = ...

local defaultConfig = {1, 0, 1, 0.6}  -- r, g, b, a

local handleEvent = function(frame, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == thisAddonName and _G["CursorHighlightConfig"] == nil then
            _G["CursorHighlightConfig"] = defaultConfig
            frame:UnregisterEvent("ADDON_LOADED")
        end
    end
end

local Options = {
    ["setColor"] = function(info, r, g, b, a)
        _G["CursorHighlightConfig"] = {r, g, b, a}
    end,

    ["getColor"] = function(info)
        local config = _G["CursorHighlightConfig"]
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
