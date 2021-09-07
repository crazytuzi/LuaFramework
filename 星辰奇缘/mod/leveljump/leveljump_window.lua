--作者:hzf
--03/14/2017 15:00:56
--功能:卡级主界面

LevelJumpWindow = LevelJumpWindow or BaseClass(BaseWindow)
function LevelJumpWindow:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.leveljumpwindow, type = AssetType.Main},
		{file = AssetConfig.dailyicon, type = AssetType.Dep},
		{file = AssetConfig.leveljumptexture, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
end

function LevelJumpWindow:__delete()
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function LevelJumpWindow:OnHide()

end

function LevelJumpWindow:OnOpen()

end

function LevelJumpWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.leveljumpwindow))
	self.gameObject.name = "LevelJumpWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.MainCon = self.transform:Find("MainCon")
	self.bg = self.transform:Find("MainCon/bg")
	self.Title = self.transform:Find("MainCon/Title")
	self.TitleText = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
	self.TitleText.text = TI18N("等级跃升")
	self.Top = self.transform:Find("MainCon/Top")
	self.MidText = self.transform:Find("MainCon/Top/MidText"):GetComponent(Text)
	self.currLevText = self.transform:Find("MainCon/Top/currLevText"):GetComponent(Text)
	self.currText = self.transform:Find("MainCon/Top/currText"):GetComponent(Text)
	self.nectLevText = self.transform:Find("MainCon/Top/nectLevText"):GetComponent(Text)
	self.nextText = self.transform:Find("MainCon/Top/nextText"):GetComponent(Text)
	self.RateBar = self.transform:Find("MainCon/Top/RateBar")
	self.Bar = self.transform:Find("MainCon/Top/RateBar/Bar")
	self.RateText = self.transform:Find("MainCon/Top/Rate"):GetComponent(Text)
	self.SubTitle = self.transform:Find("MainCon/SubTitle")
	self.SubTitleText = self.transform:Find("MainCon/SubTitle/Text"):GetComponent(Text)

	self.ItemCon = self.transform:Find("MainCon/ItemCon")
	self.MaskScroll = self.transform:Find("MainCon/ItemCon/MaskScroll")
	self.Layout = self.transform:Find("MainCon/ItemCon/MaskScroll/Layout")
	local setting1 = {
        column = 3
        ,cspacing = 4
        ,rspacing = 3
        ,cellSizeX = 200
        ,cellSizeY = 74
    }
    self.Layout1 = LuaGridLayout.New(self.Layout, setting1)
	self.BaseButton = self.transform:Find("MainCon/ItemCon/MaskScroll/Layout/Button").gameObject
	self.BaseButton:SetActive(false)
	-- self.NameText = self.transform:Find("MainCon/ItemCon/MaskScroll/Layout/Button/NameText"):GetComponent(Text)
	-- self.DescText = self.transform:Find("MainCon/ItemCon/MaskScroll/Layout/Button/DescText"):GetComponent(Text)
	-- self.Icon = self.transform:Find("MainCon/ItemCon/MaskScroll/Layout/Button/Icon")
	self.Arrow = self.transform:Find("MainCon/Arrow").gameObject

	self.CancleButton = self.transform:Find("MainCon/CancleButton"):GetComponent(Button)
	self.CancleButton.onClick:AddListener(function()
		self.model:CloseWindow()
	end)
	-- self.Text = self.transform:Find("MainCon/CancleButton/Text"):GetComponent(Text)

	self.OKButton = self.transform:Find("MainCon/OKButton"):GetComponent(Button)

	-- self.Text = self.transform:Find("MainCon/OKButton/Text"):GetComponent(Text)

	self.AboutButton = self.transform:Find("MainCon/AboutButton"):GetComponent(Button)
	self.AboutButton.onClick:AddListener(function()
		self.model:OpenScorePanel()
	end)
	-- self.Text = self.transform:Find("MainCon/AboutButton/Text"):GetComponent(Text)

	self.CloseButton = self.transform:Find("CloseButton"):GetComponent(Button)
	self.CloseButton.onClick:AddListener(function()
		self.model:CloseWindow()
	end)
	self.Toggle = self.transform:Find("MainCon/Toggle"):GetComponent(Toggle)
	self.Toggle.isOn = PlayerPrefs.GetString("Jumplev") == "1"
	self.Toggle.onValueChanged:AddListener(function(val)
		self:OnToggleChange(val)
	end)
	self:SetLev()
	self:InitList()
end

function LevelJumpWindow:InitList()
	local temp = {}
	local currlev = RoleManager.Instance.RoleData.lev
	local currBreak = RoleManager.Instance.RoleData.lev_break_times
	for i,data in ipairs(DataLevup.data_levlock) do
		if data.lev == currlev and data.break_times == currBreak then
			table.insert(temp, data)
		end
	end
	for i,v in ipairs(temp) do
		self:CreateItem(v)
	end
	self.Arrow:SetActive(#temp > 6)
end

function LevelJumpWindow:CreateItem(data)
	local go = GameObject.Instantiate(self.BaseButton)
	local gotransform = go.transform
	gotransform:GetComponent(Button).onClick:AddListener(function()
		TipsManager.Instance:ShowText({gameObject = go, itemData = {data.tips}})
	end)
	gotransform:Find("NameText"):GetComponent(Text).text = data.name
	gotransform:Find("DescText"):GetComponent(Text).text = data.desc
	gotransform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, data.icon)
	self.Layout1:AddCell(go)
end

function LevelJumpWindow:SetLev()
	local currlev = RoleManager.Instance.RoleData.lev
	local currexp = RoleManager.Instance.RoleData.exp
	local maxexp = DataLevup.data_levup[currlev].exp
	local countexp = 0
	local jumplev = 0
	self.SubTitleText.text = string.format(TI18N("%s级解锁内容"), tostring(currlev+1))
	for i,v in ipairs(DataLevup.data_levup) do
		if v.lev >= currlev and countexp < currexp then
			countexp = countexp +v.exp
			jumplev = v.lev
		else
			-- break
		end
	end
	-- if jumplev - 5 >= currlev then
	-- 	self.MidText.text = TI18N("<color='#ffff00'>已到达经验上限</color>")
	-- else
		self.MidText.text = TI18N("已累积经验")
	-- end
	self.currLevText.text = tostring(currlev)
	if jumplev > currlev then
		self.nectLevText.text = tostring(jumplev)
		self.nextText.text = "可跃升等级"
		self.Toggle.gameObject:SetActive(true)
	else
		self.nextText.text = "经验不足"
		self.nectLevText.text = tostring(currlev+1)
		self.Toggle.gameObject:SetActive(false)
	end
	self.Bar.sizeDelta = Vector2(385*math.min(1, currexp/maxexp), 17.7)
	self.RateText.text = string.format("%.1f%%", math.floor(currexp/maxexp*1000)/10)

	self.OKButton.onClick:AddListener(function()
		if jumplev > currlev then
			-- local data = NoticeConfirmData.New()
			-- data.type = ConfirmData.Style.Normal
			-- data.content = string.format(TI18N("跃升后可到达等级:<color='#ffff00'>%s</color>,是否跃升？"), jumplev)
			-- data.sureLabel = TI18N("确定跃升")
			-- data.cancelLabel = TI18N("我考虑下")
			-- data.sureCallback = function()
			-- 		LuaTimer.Add(50, function()
			-- 			local isGodsWar = self:CheckGodsWar(jumplev)
			-- 			if not isGodsWar then
			-- 				RoleManager.Instance:send10034()
			-- 				self.model:CloseWindow()
			-- 			end
			-- 		end)
			--     end
			-- NoticeManager.Instance:ConfirmTips(data)
			local Querdata = {
			    titleTop = TI18N("确认跃升")
			    , title = string.format(TI18N("跃升后可达等级:<color='#ffff00'>%d</color>,输入验证码可跃升"),jumplev)
			    , password = TI18N(tostring(math.random(1000, 9999)))
			    , confirm_str = TI18N("跃 升")
			    , cancel_str = TI18N("取 消")
			    , confirm_callback = function()
			        LuaTimer.Add(50, function()
			            local isGodsWar = self:CheckGodsWar(jumplev)
			            if not isGodsWar then
			                RoleManager.Instance:send10034()
			                self.model:CloseWindow()
			            end
			        end)
			    end
			}
			TipsManager.Instance.model:OpentwiceConfirmPanel(Querdata)
		else
			NoticeManager.Instance:FloatTipsByString(TI18N("经验达到<color='#ffff00'>100%</color>再来跃升吧"))
		end
	end)
end

function LevelJumpWindow:OnToggleChange(isOn)
	if isOn then
		PlayerPrefs.SetString("Jumplev", "1")
		NoticeManager.Instance:FloatTipsByString(TI18N("已关闭<color='#ffff00'>[提升-等级可跃升]</color>提示"))
	else
		PlayerPrefs.SetString("Jumplev", "0")
		NoticeManager.Instance:FloatTipsByString(TI18N("已开启<color='#ffff00'>[提升-等级可跃升]</color>提示"))
	end
	ImproveManager.Instance:OnStatusChange(true)
end

function LevelJumpWindow:CheckGodsWar(jumplev)
	if GodsWarManager.Instance.myData ~= nil and GodsWarManager.Instance.myData.tid ~= 0 then
		if GodsWarManager.Instance.status > GodsWarEumn.Step.Sign then
			local gruopLev = GodsWarEumn.GetGruopLev(GodsWarManager.Instance.myData.lev)
			if jumplev > gruopLev.max_lev then
				local data = NoticeConfirmData.New()
				data.type = ConfirmData.Style.Normal
				data.content = string.format(TI18N("您正在参与诸神之战%s，若等级超过'%s+3级'，将失去参赛资格，是否确定升级？"), gruopLev.name, gruopLev.max_lev)
				data.sureLabel = TI18N("确定升级")
				data.cancelLabel = TI18N("我考虑下")
				data.sureCallback = function()
						RoleManager.Instance:send10034()
						self.model:CloseWindow()
				    end
				NoticeManager.Instance:ConfirmTips(data)

				return true
			end
		else
			local gruopLev = GodsWarEumn.GetGruopLev(GodsWarManager.Instance.myData.lev)
			if  jumplev > gruopLev.max_lev then
				local data = NoticeConfirmData.New()
				data.type = ConfirmData.Style.Normal
				data.content = string.format(TI18N("您正在参与诸神之战（报名阶段），若等级超过%s级，将自动分配至下一组别，是否确定升级？"), gruopLev.max_lev)
				data.sureLabel = TI18N("确定升级")
				data.cancelLabel = TI18N("我考虑下")
				data.sureCallback = function()
						RoleManager.Instance:send10034()
						self.model:CloseWindow()
				    end
				NoticeManager.Instance:ConfirmTips(data)

				return true
			end
		end
	end
end