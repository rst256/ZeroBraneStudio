local G = ...
local serpent = G.require("serpent")

local function _onEditorCharAdded(self, ...)
	local uimgr = ide:GetUIManager()
	local pane = uimgr:GetPane'bottomnotebook'
	if pane:IsShown() then
		pane:BestSize(pane.window:GetSize())
		pane:Show(false)
		uimgr:Update()
	end
	self.onEditorCharAdded = nil
end

return {
	name = "OutputAutoHide",
	description = "Hide output panel onEditorCharAdded",
	author = "rst256",
	version = 0.1,
	dependencies = 1.3,

	onActivateOutput = function(self, ...)
		self.onEditorCharAdded = _onEditorCharAdded
	end

}
