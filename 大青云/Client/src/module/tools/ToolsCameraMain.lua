_G.UIToolsCameraMain = BaseUI:new("UIToolsCameraMain")
UIToolsCameraMain.StoryData = {}	--当前地图中的所有的数据
UIToolsCameraMain.StorysList = {}	--剧情标题combox的dataProvider
UIToolsCameraMain.CurrentStory = {}
UIToolsCameraMain.CurrentStoryname = ''
_G.IsCameraToolsShow = false

function UIToolsCameraMain:Create()
	self:AddSWF("toolsCamaraMain.swf",true,"center")
end

function UIToolsCameraMain:OnLoaded(objSwf,name)

	objSwf.btnClose.click = function()  self:Lock() self:OnBtnCloseClick();end
	objSwf.dropmenu.change = function(e) self:Lock() self:OnDropMenuClick(e); end
	objSwf.dropmenu.rowCount = 50;
	objSwf.camaraList.itemClick = function(e) self:Lock() self:OnCamaraListClick(e) end
	
	objSwf.btnTAdd.click = function() self:Lock() self:OnStoryAdd() end
	objSwf.btnTDel.click = function() self:Lock() self:OnStoryDel() end
	
	objSwf.btnAdd.click = function() self:Lock() self:OnCameraAdd() end
	objSwf.btnEdit.click = function() self:Lock() self:OnCameraEdit() end
	objSwf.btnDel.click = function() self:Lock() self:OnCameraDel() end
	
	objSwf.btnSave.click = function() self:Lock() self:OnSave() end
	objSwf.btnPreView.click = function() self:Lock() self:OnPreview() end
	objSwf.btnLock.visible = false
	objSwf.btnLock.click = function() 
		self:Lock()
	end
	objSwf.btnExport.click = function()
		self:ExportRes()
	end
	
	objSwf.panelNew._visible = false
end

-- function AppManager:OnMouseWheel(d)
	-- _rd.camera:moveRadius(d * -0.1 * _rd.camera.radius)
-- end

function UIToolsCameraMain:Lock()
	local player =  MainPlayerController:GetPlayer()
	if player then
		player:GetAvatar():DisableCameraFollow()
	end
end

-- camTracks self.StoryData
-- track self.StorysList
-- camTrack self.CurrentStory
function UIToolsCameraMain:OnShow(name)
	local objSwf = self:GetSWF("UIToolsCameraMain") 
	if not objSwf then return end
	_G.IsCameraToolsShow = true
	
	local player =  MainPlayerController:GetPlayer()
	if player then
		player:GetAvatar():DisableCameraFollow()
	end
	
	-- SpiritsUtil:Print(CPlayerMap:GetCurMapID())
	self.StoryData = StoryConfig[CPlayerMap:GetCurMapID()] or {}
	
	self:SetCBoxList()
end

function UIToolsCameraMain:SetCBoxList()
	local objSwf = self:GetSWF("UIToolsCameraMain") 
	if not objSwf then return end

	self.StorysList = {}
	objSwf.dropmenu.dataProvider:cleanUp();
	if self.StoryData then
		for id,v in pairs(self.StoryData) do
			if id~=0 then
				table.push(self.StorysList, id )
				objSwf.dropmenu.dataProvider:push(id)
			end
		end
					
	else
		table.push(self.StorysList, '无')
		objSwf.dropmenu.dataProvider:push('无')
	end
	objSwf.dropmenu:invalidateData();
	
	SpiritsUtil:Trace(self.StorysList)
	objSwf.dropmenu.selectedIndex = 0	
end

function UIToolsCameraMain:SetCamaraList()
	local objSwf = self:GetSWF("UIToolsCameraMain") 
	if not objSwf then return end

	local dp = {}
	local dp1 = {}
	local dp2 = {}
	local sname = self.StorysList[objSwf.dropmenu.selectedIndex + 1]
	self.CurrentStory = self.StoryData[sname] or {}
	self.CurrentStoryname = sname
	table.sort(self.CurrentStory,function(A,B)
		if A.cname < B.cname then
			return true;
		else
			return false;
		end
	end);
	objSwf.camaraList.dataProvider:cleanUp() 
	for id,v in ipairs(self.CurrentStory) do
		local node = {}
		node.cname = v.cname
		node.pos = v.pos
		node.talkStr = v.talkStr
		node.maxTime = v.maxTime
		node.lastTime = v.lastTime
		node.bCam = v.bCam
		node.playerMovePos = v.playerMovePos
		node.npcId = v.npcId
		node.shakeTime = v.shakeTime
		objSwf.camaraList.dataProvider:push( UIData.encode(node) )
	end
	objSwf.camaraList:invalidateData()
end
function UIToolsCameraMain:OnSave()
	StoryConfig[CPlayerMap:GetCurMapID()] = self.StoryData
	local exportDic = self:Sort1()	
	local f = _File.new()
	local filename = ClientConfigPath .. 'config/storyConfig/StoryConfig.lua'
	f:create( filename )
	local s = table.tostr(exportDic)
	s = string.gsub(s,'},','},\n')
	f:write( '_G.StoryConfig= \n'..s )
	f:close()
end

function UIToolsCameraMain:Sort1()
	local storyDic = {}
	local sortArray = {}
	for n in pairs(StoryConfig) do
		sortArray[#sortArray + 1] = n
	end
	table.sort(sortArray)
	FTrace(sortArray)
	for i,n in ipairs(sortArray) do
		storyDic[n] = self:Sort2(StoryConfig[n])
	end
	
	return storyDic
end

function UIToolsCameraMain:Sort2(cfg)
	local storyDic = {}
	local sortArray = {}
	for n in pairs(cfg) do
		sortArray[#sortArray + 1] = n
	end
	table.sort(sortArray)
	FTrace(sortArray)
	for i,n in ipairs(sortArray) do
		-- self:Sort3(cfg[n])
		storyDic[n] = self:Sort4(cfg[n])
	end
	
	return storyDic
end

function UIToolsCameraMain:Sort3(storyDic)
	table.sort(storyDic,function(A,B)
		if A.cname < B.cname then
			return true;
		else
			return false;
		end
	end);
end

function UIToolsCameraMain:Sort4(cfg)
	local storyDic = {}
	self:Sort3(cfg)	
	for i,n in ipairs(cfg) do
		storyDic[i] = self:Sort5(cfg[i])
	end
	
	return storyDic
end

function UIToolsCameraMain:Sort5(cfg)
	local storyDic = {}
	local sortArray = {}
	for n in pairs(cfg) do
		sortArray[#sortArray + 1] = n
	end
	table.sort(sortArray)
	-- FTrace(sortArray)
	for i,n in ipairs(sortArray) do
		-- self:Sort3(cfg[n])
		storyDic[n] = cfg[n]
	end
	
	return storyDic
end

function UIToolsCameraMain:ExportRes()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/storyconfig/StoryResList.lua');
	file:write("--[[ 剧情提前加载资源\nliyuan\n]]\n".."_G.StoryResList = {\n");
	for mapId,modelList in pairs (_ResListCfg) do
		file:write("\t["..mapId.."] = \n\t{\n");
		for modelId, act in pairs (modelList) do
			if modelId >= 1 and modelId <= 100 then
				file:write("\t\t--主角动作"..act.."\n")
				for i = 1,4 do
					local actId = i*100 + toint(act)
					local juqingActCfg = t_juqing_action[actId]
					if juqingActCfg then
						file:write("\t\t'"..juqingActCfg.san.."',\n")
					end
				end
			else
				local model = t_model[modelId]
				if not model then FPrint('没有找到modelId:'..modelId) end
				file:write("\t\t--ModelId ="..modelId.."\n")
				file:write("\t\t'"..model.skl.."',\n")
				file:write("\t\t'"..model.skn.."',\n")
				for k,v in pairs (act) do
					file:write("\t\t'"..model[v].."',\n")
				end
			end
		end
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

function UIToolsCameraMain:OnPreview()
	if self.CurrentStoryname and self.CurrentStoryname~= '' then
		StoryController:StoryStartMsg(self.CurrentStoryname, nil, true)
	end
end

--点击切换线
function UIToolsCameraMain:OnDropMenuClick(e)
	self:SetCamaraList()
end

-- 选中某个
UIToolsCameraMain.SelectedCameraName = nil
function UIToolsCameraMain:OnCamaraListClick(e)
	if not self.CurrentStory then SpiritsUtil:Print('当前剧情为空') return end
	
	-- SpiritsUtil:Print(e.item.cname)
	self.SelectedCameraName = toint(e.item.cname)
	
	self:OnCameraEdit()
end

function UIToolsCameraMain:OnCameraEdit()
	if not self.CurrentStory then SpiritsUtil:Print('当前剧情为空') return end
	if not self.SelectedCameraName then SpiritsUtil:Print('当前选中的摄像机为空') return end
	
	local curCameraVO = self.CurrentStory[toint(self.SelectedCameraName)]
	FPrint(toint(self.SelectedCameraName))
	
	if not UIToolsCamera:IsShow() then
		UIToolsCamera:Show()
	else
		if not curCameraVO then return end
		UIToolsCamera:OnEdit(curCameraVO)
	end
end

function UIToolsCameraMain:OnCameraDel()
	if not self.CurrentStory then SpiritsUtil:Print('当前剧情为空') return end
	if not self.SelectedCameraName then SpiritsUtil:Print('当前选中的摄像机为空') return end
	
	table.remove(self.CurrentStory, toint(self.SelectedCameraName))
	for id,v in ipairs(self.CurrentStory) do
		v.cname = id
	end
	
	self:SetCamaraList()
end

function UIToolsCameraMain:OnStoryAdd()
	local objSwf = self:GetSWF("UIToolsCameraMain") 
	if not objSwf then return end
	
	objSwf.panelNew._visible = true
	objSwf.panelNew.btnSave.click = function()
		local sName = objSwf.panelNew.inputStoryId.text or '' 
		if sName ~= '' then 
			self.StoryData[sName] = {}
		else
			local index = 1
			for i,v in pairs(self.StoryData) do
				if 'New' == string.sub(i, 1, 3) then
					index = index + 1
				end
			end
			
			self.StoryData['New'..index] = {}
		end
		self:SetCBoxList()
		objSwf.panelNew._visible = false
	end
	objSwf.panelNew.btnClose.click = function()
		objSwf.panelNew._visible = false
	end
	objSwf.panelNew.btnCancel.click = function()
		objSwf.panelNew._visible = false
	end
end

function UIToolsCameraMain:OnStoryDel()
	local objSwf = self:GetSWF("UIToolsCameraMain") 
	if not objSwf then return end
	
	local sname = self.StorysList[objSwf.dropmenu.selectedIndex + 1]
	self.StoryData[sname] = nil
	self:SetCBoxList()
end

function UIToolsCameraMain:OnCameraAdd()
	if not self.CurrentStory then SpiritsUtil:Print('当前剧情为空') return end
	local cVO = nil
	if #self.CurrentStory > 0 then 
		if not self.SelectedCameraName then FPrint('当前选中为空') return end
		cVO = CamaraCfgVO:new()
		table.insert(self.CurrentStory, self.SelectedCameraName + 1, cVO)
	else
		cVO = CamaraCfgVO:new()
		table.insert(self.CurrentStory, 1, cVO)
	end
	
	for id,v in ipairs(self.CurrentStory) do
		v.cname = id
	end
	
	if not UIToolsCamera:IsShow() then
		UIToolsCamera:Show()
	else
		UIToolsCamera:OnEdit(cVO)
	end
	
	self:SetCamaraList()
end

function UIToolsCameraMain:OnbtnSaveClick()
	
end

--配置变动
function UIToolsCameraMain:OnCfgChange()
	
end

function UIToolsCameraMain:OnHide()
	_G.IsCameraToolsShow = false
	CPlayerControl:ResetCameraPos(1000)
	local player =  MainPlayerController:GetPlayer()
	if player then
		player:GetAvatar():SetCameraFollow()
	end
end

function UIToolsCameraMain:OnBtnCloseClick()
	self:Hide();
end
