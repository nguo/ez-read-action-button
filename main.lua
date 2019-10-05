EzReadActionButton = {
	name = "EzReadActionButton"
}
local ezRAB = EzReadActionButton

local ADDON_NAME = "EzReadActionButton"

local HotkeyChanger = CreateFrame("Frame", ezRAB.name, _G.InterfaceOptionsFrame)

-- action button properties - taken from dominos and BT4
local NUM_BT4_BUTTONS = 120
local NUM_DOM_BUTTONS = 60
local DEF_ACTION_BTN_NAME = "ActionButton"
local MULTI_R_BTN_NAME = "MultiBarRightButton"
local MULTI_L_BTN_NAME = "MultiBarLeftButton"
local MULTI_BR_BTN_NAME = "MultiBarBottomRightButton"
local MULTI_BL_BTN_NAME = "MultiBarBottomLeftButton"
local DEF_PET_BTN_NAME = "PetActionButton"
local DOM_ACTION_BTN_NAME = "DominosActionButton"
local BT_ACTION_BTN_NAME = "BT4Button"
local BT_PET_BTN_NAME = "BT4PetButton"

function HotkeyChanger:Startup()
	self:SetupEvents()
end

function HotkeyChanger:SetupEvents()
	self:SetScript("OnEvent", function(f, event, ...)
		-- for k,v in pairs(_G) do
		--   if  string.find(k, 'BT4', 1, true) and string.find(k, 'HotKey') then
		--   	print("--------", k)
		--   end
		-- end
		self:Init()
	end)
	-- hook on to a late event to give time for other addons to create their action buttons
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
end

function HotkeyChanger:setupHotkeyColor(hotkey, button)
	if hotkey == nil then
		return
	end
	hotkey:SetTextColor(ezRAB.db.hotkey.defaultColor[1], ezRAB.db.hotkey.defaultColor[2], ezRAB.db.hotkey.defaultColor[3])

	-- TODO: BT4 doesn't hook into SetVertexColor all the time - use own event timer handler instead?

	-- hook into function that is called by the game to update color of text based on range
	hooksecurefunc(hotkey, "SetVertexColor", function(...)
		self:updateHotkeyColor(hotkey, button)
	end)
end

function HotkeyChanger:updateHotkeyColor(hotkey, button)
	if ezRAB.db.hotkey.useColorIndicators == false then
		hotkey:SetTextColor(ezRAB.db.hotkey.defaultColor[1], ezRAB.db.hotkey.defaultColor[2], ezRAB.db.hotkey.defaultColor[3])
		return
	end
	if button == nil then
		hotkey:SetTextColor(ezRAB.db.hotkey.defaultColor[1], ezRAB.db.hotkey.defaultColor[2], ezRAB.db.hotkey.defaultColor[3])
		print("No button to detect action range on")
		return
	end

	-- button._state_action is BT4 specific
	local actionId = button._state_action ~= nil and button._state_action or button.action
	local isUsable, notEnoughMana = _G.IsUsableAction(actionId)
	if isUsable then
		if _G.IsActionInRange(actionId) == false then
			hotkey:SetTextColor(ezRAB.db.hotkey.outOfRangeColor[1], ezRAB.db.hotkey.outOfRangeColor[2], ezRAB.db.hotkey.outOfRangeColor[3])
		else
			hotkey:SetTextColor(ezRAB.db.hotkey.defaultColor[1], ezRAB.db.hotkey.defaultColor[2], ezRAB.db.hotkey.defaultColor[3])
		end
	elseif notEnoughMana == true then
		hotkey:SetTextColor(ezRAB.db.hotkey.oomColor[1], ezRAB.db.hotkey.oomColor[2], ezRAB.db.hotkey.oomColor[3])
	else
		hotkey:SetTextColor(ezRAB.db.hotkey.defaultColor[1], ezRAB.db.hotkey.defaultColor[2], ezRAB.db.hotkey.defaultColor[3])
	end
end

function HotkeyChanger:Init()
	-------------------------------------------------------
	-- for action buttons
	-------------------------------------------------------

	local usingBt = _G[""..BT_ACTION_BTN_NAME.."1HotKey"] ~= nil
	local usingDominos = _G[""..DOM_ACTION_BTN_NAME.."1HotKey"] ~= nil
	local barNames = usingBt and {BT_ACTION_BTN_NAME} or {DEF_ACTION_BTN_NAME, MULTI_L_BTN_NAME, MULTI_R_BTN_NAME, MULTI_BL_BTN_NAME, MULTI_BR_BTN_NAME}
	local maxNum = usingBt and NUM_BT4_BUTTONS or NUM_ACTIONBAR_BUTTONS
	if usingDominos then
		maxNum = NUM_DOM_BUTTONS
		table.insert(barNames, DOM_ACTION_BTN_NAME)
	end
	for _, barName in pairs(barNames) do
		for i = 1, maxNum do
			local hotkey = _G[""..barName..i.."HotKey"]
			if hotkey and hotkey:GetText() then
				-- TODO: "Count" position to prevent overlap of hotkey text?
				local button = _G[""..barName..i]
				hotkey:SetFont(ezRAB.db.hotkey.fontName, ezRAB.db.hotkey.fontSize, "THICKOUTLINE")
				hotkey:SetPoint("TOPLEFT", button, "TOPLEFT", ezRAB.db.hotkey.posOffset[1], ezRAB.db.hotkey.posOffset[2])
				self:setupHotkeyColor(hotkey, button)
			end
		end
	end

	-------------------------------------------------------
	-- for pet
	-------------------------------------------------------

	local buttonKey = usingBt and BT_PET_BTN_NAME or DEF_PET_BTN_NAME
	for i = 1, NUM_PET_ACTION_SLOTS do
		local hotkey = _G[""..buttonKey..i.."HotKey"]
		if hotkey then
			local button = _G[""..buttonKey..i]
			hotkey:SetFont(ezRAB.db.hotkey.fontName, ezRAB.db.hotkey.petFontSize, "THICKOUTLINE")
			hotkey:SetPoint("TOPLEFT", button, "TOPLEFT", ezRAB.db.hotkey.petPosOffset[1], ezRAB.db.hotkey.petPosOffset[2])
			self:setupHotkeyColor(hotkey, button)
		end
	end
end

HotkeyChanger:Startup()
