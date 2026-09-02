local UEHelpers = require("UEHelpers")
local M = {}

M.textures = {
	icon_Build = "/Game/UI/Images/T_UI_Build.T_UI_Build",
	icon_Sleep = "/Game/UI/Images/FlagIcons/T_UI_Flag_Sleep.T_UI_Flag_Sleep",
	icon_Zipline = "/Game/Blueprints/Items/Icons/Buildings/ICO_BLDG_Zipline_Anchor.ICO_BLDG_Zipline_Anchor",
	icon_CancelBuild = "/Game/UI/Images/ActionIcons/T_UI_CancelBuild.T_UI_CancelBuild",
	icon_Science_RS = "/Game/UI/Images/T_UI_Science_MainChunk.T_UI_Science_MainChunk",
	icon_ChatStop = "/Game/UI/Images/Chat/T_UI_Chat_Stop.T_UI_Chat_Stop",
	icon_Storage = "/Game/UI/Images/T_UI_Storage.T_UI_Storage",
}

---@param objectFullName string
---@param variableName string
---@param forceInvalidateCache boolean | nil
---@return UObject
local function CacheDefaultObject(objectFullName, variableName, forceInvalidateCache)
	local DefaultObject

	if not forceInvalidateCache then
		DefaultObject = ModRef:GetSharedVariable(variableName)
		if DefaultObject and DefaultObject:IsValid() then
			return DefaultObject
		end
	end

	DefaultObject = StaticFindObject(objectFullName)
	ModRef:SetSharedVariable(variableName, DefaultObject)
	if not DefaultObject:IsValid() then
		error(string.format("%s not found", objectFullName))
	end

	return DefaultObject
end

---Note: Must be executed in the game thread.
---@param message string The message content to display.
---@param texturePath string Path to the texture asset.
function M.ShowMessage(message, texturePath)
	local statics = M.GetUserInterfaceStatics(false)
	if not statics or not statics:IsValid() then
		return
	end

	local viewport = UEHelpers.GetGameViewportClient()
	if not viewport:IsValid() then
		return
	end

	local ui = statics:GetGameUI(viewport)
	if not ui:IsValid() then
		return
	end

	local obj = StaticFindObject(texturePath)

	---@cast obj UTexture2D
	if not obj:IsValid() then
		-- load texture
		LoadAsset(texturePath)
	end
	if not obj then
		return
	end

	-- display message with icon
	---@diagnostic disable-next-line: undefined-global
	ui:PostGenericMessage(FString(message), obj)
end

---@param message string
function M.PostPlayerChatMessage(message)
	local uistatics = M.GetUserInterfaceStatics(false)
	local survivalGameplayStatics = M.GetSurvivalGameplayStatics()

	---@cast uistatics UUserInterfaceStatics
	---@cast survivalGameplayStatics USurvivalGameplayStatics

	if uistatics and survivalGameplayStatics then
		local ui = uistatics:GetGameUI(UEHelpers.GetGameViewportClient())
		local state = survivalGameplayStatics:GetLocalSurvivalPlayerState(UEHelpers.GetGameViewportClient())

		---@diagnostic disable-next-line: undefined-global
		ui:PostPlayerChatMessage(FString(message), state)
	end
end

---@param ForceInvalidateCache boolean | nil
---@return USurvivalGameplayStatics
function M.GetSurvivalGameplayStatics(ForceInvalidateCache)
	---@diagnostic disable-next-line: return-type-mismatch
	return CacheDefaultObject(
		"/Script/Maine.Default__SurvivalGameplayStatics",
		"Grounded_SurvivalGameplayStatics",
		ForceInvalidateCache
	)
end

---@param ForceInvalidateCache boolean
---@return UUserInterfaceStatics
function M.GetUserInterfaceStatics(ForceInvalidateCache)
	---@diagnostic disable-next-line: return-type-mismatch
	return CacheDefaultObject(
		"/Script/Maine.Default__UserInterfaceStatics",
		"Grounded_UserInterfaceStatics",
		ForceInvalidateCache
	)
end

---@return ASurvivalPlayerCharacter
function M.GetLocalSurvivalPlayerCharacter()
	local statics = M.GetSurvivalGameplayStatics()
	local world = UEHelpers.GetWorldContextObject()
	if not statics:IsValid() or not world:IsValid() then
		return CreateInvalidObject() ---@type ASurvivalPlayerCharacter
	end

	return statics:GetLocalSurvivalPlayerCharacter(world)
end

---@return ASurvivalPlayerController
function M.GetLocalSurvivalPlayerController()
	local statics = M.GetSurvivalGameplayStatics()
	local world = UEHelpers.GetWorldContextObject()
	if not statics:IsValid() or not world:IsValid() then
		return CreateInvalidObject() ---@type ASurvivalPlayerController
	end

	return statics:GetLocalSurvivalPlayerController(world)
end

return M
