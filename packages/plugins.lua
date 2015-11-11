local G = ...

local main_frame
local wxID_pman_show_dialog = G.ID("pkgman.show_dialog")

local function pkg_path(name, state)
	local path = MergeFullPath(
    GetPathWithSep(ide.editorFilename), "packages/"..(name or ''))
	if name==nil or name=='' then return path end
	if state==nil then
		return path..iff(wx.wxFileExists(path..'.lua'), '.lua', '.lua.off')
	else
		return path..iff(state, '.lua', '.lua.off')
	end
end


local function DisablePackage(k)
	if not wx.wxFileExists(pkg_path(k, true)) then
		DisplayOutputLn("Disable package: "..k..'\tFail, file not found')
	else
		if not wx.wxFileExists(pkg_path(k, false)) then
			wx.wxRenameFile(pkg_path(k, true), pkg_path(k, false))
		else
			DisplayOutputLn("Disable package: "..k..'\tFail, file already exists')
		end
	end
end

local function EnablePackage(k)
	if not wx.wxFileExists(pkg_path(k, false)) then
		DisplayOutputLn("Enable package: "..k..'\tFail, file not found')
	else
		if not wx.wxFileExists(pkg_path(k, true)) then
			wx.wxRenameFile(pkg_path(k, false), pkg_path(k, true))
		else
			DisplayOutputLn("Enable package: "..k..'\tFail, file already exists')
		end
	end
end

local function CreateDialog(parent, title, list, on_select)
	UI = {}

	UI.MyDialog1 = wx.wxDialog(parent or wx.NULL, wx.wxID_ANY, title, wx.wxDefaultPosition, wx.wxSize(600, 400), wx.wxDEFAULT_DIALOG_STYLE+		wx.wxRESIZE_BORDER )
	UI.MyDialog1:SetSizeHints( wx.wxDefaultSize, wx.wxDefaultSize )

	UI.bSizer1 = wx.wxBoxSizer( wx.wxVERTICAL )

	UI.bSizer2 = wx.wxBoxSizer( wx.wxHORIZONTAL )

	UI.m_checkList1 = wx.wxListBox( UI.MyDialog1, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize, list, wx.wxLB_SORT )
	UI.bSizer2:Add( UI.m_checkList1, 1, wx.wxALL + wx.wxEXPAND, 5 )

	UI.m_textCtrl1 = wx.wxTextCtrl( UI.MyDialog1, wx.wxID_ANY, "", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE + wx.wxTE_READONLY )
	UI.bSizer2:Add( UI.m_textCtrl1, 1, wx.wxALL + wx.wxEXPAND, 5 )


	UI.bSizer1:Add( UI.bSizer2, 1, wx.wxEXPAND, 5 )

	UI.bSizer3 = wx.wxBoxSizer( wx.wxHORIZONTAL )

	UI.Load = wx.wxButton( UI.MyDialog1, wx.wxID_ANY, "Load", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer3:Add( UI.Load, 1, wx.wxALL + wx.wxEXPAND, 5 )

	UI.UnLoad = wx.wxButton( UI.MyDialog1, wx.wxID_ANY, "UnLoad", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer3:Add( UI.UnLoad, 1, wx.wxALL + wx.wxEXPAND, 5 )

	UI.Disable = wx.wxButton( UI.MyDialog1, wx.wxID_ANY, "Disable", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer3:Add( UI.Disable, 1, wx.wxALL + wx.wxEXPAND, 5 )

	UI.Enable = wx.wxButton( UI.MyDialog1, wx.wxID_ANY, "Enable", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer3:Add( UI.Enable, 1, wx.wxALL + wx.wxEXPAND, 5 )

	UI.Reload = wx.wxButton( UI.MyDialog1, wx.wxID_ANY, "Reload", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer3:Add( UI.Reload, 1, wx.wxALL + wx.wxEXPAND, 5 )

	UI.Edit = wx.wxButton( UI.MyDialog1, wx.wxID_ANY, "Edit", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer3:Add( UI.Edit, 1, wx.wxALL + wx.wxEXPAND, 5 )
	UI.Edit:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
		LoadFile(pkg_path(UI.m_checkList1:GetStringSelection()))
	end )

	UI.bSizer1:Add( UI.bSizer3, 0, wx.wxEXPAND, 5 )

	local function on_selected()
		local issel = UI.m_checkList1:GetSelection() ~= -1
		local name = UI.m_checkList1:GetStringSelection()
		local enabled = wx.wxFileExists(pkg_path(name, true))
		UI.Reload:Enable( issel and ide.packages[name]~=nil and enabled )
		UI.Edit:Enable( issel )
		UI.Disable:Enable( issel and enabled )
		UI.Enable:Enable( issel and not enabled )
		UI.Load:Enable( issel and ide.packages[name]==nil and enabled )
		UI.UnLoad:Enable( issel and ide.packages[name]~=nil )
		local s = ''
		if issel then
			s = s .. 'Package '..name .. '\n\n'
			s = s .. 'path: \t' .. pkg_path(name) .. '\n'
			if ide.packages[name] then
				for k, v in pairs(ide.packages[name]) do
					if type(v)~='function' and type(v)~='table' then
						s = s .. k .. ': \t'..tostring(v):gsub('\n', '\t\n') .. '\n'
					end
				end
			end
		end
		UI.m_textCtrl1:SetValue(s)
	end

	UI.Reload:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
		local fname = UI.m_checkList1:GetStringSelection()
		PackageUnRegister(fname)
		PackageRegister(fname)
		ide:GetMainFrame().uimgr:Update()
		on_selected()
	end )

	UI.UnLoad:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
		local fname = UI.m_checkList1:GetStringSelection()
		PackageUnRegister(fname)
		ide:GetMainFrame().uimgr:Update()
		on_selected()
	end )

	UI.Load:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
		local fname = UI.m_checkList1:GetStringSelection()
		PackageRegister(fname)
		ide:GetMainFrame().uimgr:Update()
		on_selected()
	end )

	UI.Disable:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
		local fname = UI.m_checkList1:GetStringSelection()
		DisablePackage(fname)
		ide:GetMainFrame().uimgr:Update()
		on_selected()
	end )

	UI.Enable:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
		local fname = UI.m_checkList1:GetStringSelection()
		EnablePackage(fname)
		ide:GetMainFrame().uimgr:Update()
		on_selected()
	end )

	UI.m_checkList1:Connect( wx.wxEVT_COMMAND_LISTBOX_SELECTED, on_selected )

	UI.MyDialog1:Connect( wx.wxEVT_SHOW, function(event)
		if UI.MyDialog1:IsShown() then on_selected() end
	end )


	UI.MyDialog1:SetSizer( UI.bSizer1 )
	UI.MyDialog1:Layout()
	return UI.MyDialog1
end


return {
  name = "Plugins manager",
  description = "Plugins manager tool",
  author = "rst256",
  version = 0.1,
  dependencies = 1.0,



	onAppLoad = function(self)
		local pkg_list = {}

		for k, v in pairs(ide.packages) do
			if v.name and v.description and v~=self then
				table.insert(pkg_list, k)
			end
		end

		local packages_dir = pkg_path(nil, nil)
		local fi = wx.wxFindFirstFile(packages_dir..'*.lua.off', wx.wxFILE)
		while fi and #fi>0 do
			table.insert(pkg_list, fi:sub(#packages_dir+1, #fi-8))
		 	fi = wx.wxFindNextFile()
		end



		main_frame = CreateDialog(ide:GetMainFrame(), self.name, pkg_list)

		ide:AddTool(TR(self.name), function()
			main_frame:ShowModal(not main_frame:IsShown())
		end)

  end,

  onUnRegister = function(self)
		main_frame:Hide()
		ide:RemoveTool(TR(self.name))
  end,
}

