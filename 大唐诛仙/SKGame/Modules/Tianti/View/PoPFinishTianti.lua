PoPFinishTianti = BaseClass(LuaUI)
function PoPFinishTianti:__init( ... )
	self.URL = "ui://wetrdvlhotx720";
	self:__property(...)
	self:Config()
	self:InitEvent()
end
function PoPFinishTianti:SetProperty( ... )
	
end
function PoPFinishTianti:Config()
	self.awardIcons = {}
end

function PoPFinishTianti:DestroyAwardIcons()
	for _, v in pairs(self.awardIcons) do
		if v then 
			v:Destroy()
			v = nil
		end
	end
	self.awardIcons = nil
end

function PoPFinishTianti:InitEvent()
	self.btnQueding.onClick:Add(function ()
		FBController:GetInstance():RequireQuitInstance()
	end)
end

function PoPFinishTianti:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tianti","PoPFinishTianti");

	self.victoryBg = self.ui:GetChild("victoryBg")
	self.vRole3D = self.ui:GetChild("vRole3D")
	self.n1 = self.ui:GetChild("n1")
	self.n2 = self.ui:GetChild("n2")
	self.victoryText = self.ui:GetChild("victoryText")
	self.victory = self.ui:GetChild("victory")
	self.defeatedBg = self.ui:GetChild("defeatedBg")
	self.dRole3D = self.ui:GetChild("dRole3D")
	self.n11 = self.ui:GetChild("n11")
	self.n12 = self.ui:GetChild("n12")
	self.victoryText_2 = self.ui:GetChild("victoryText_2")
	self.defeated = self.ui:GetChild("defeated")
	self.imgTimeOut = self.ui:GetChild("imgTimeOut")
	self.imgTimeOut.visible = false

	self.txtHaoshi = self.ui:GetChild("txtHaoshi")
	self.txtJifenAdd = self.ui:GetChild("txtJifenAdd")
	self.awardContainer = self.ui:GetChild("awardContainer")
	self.btnQueding = self.ui:GetChild("btnQueding")
	local tab = { self.n1, self.n2, self.n11, self.n12, self.victoryText, self.victoryText_2 }
	for i = 1, #tab do
		tab[i].visible = false
	end
	self.iconJifenFlag = self.ui:GetChild("iconJifenFlag")
	self.txtLiansheng = self.ui:GetChild("txtLiansheng")
end
function PoPFinishTianti.Create( ui, ...)
	return PoPFinishTianti.New(ui, "#", {...})
end

function PoPFinishTianti:OnEnable(rev)
	local result = rev.state
	local destroyTime = rev.destroyTime

	self.txtHaoshi.text = StringFormat("耗时:    {0}秒", rev.useTime)
	local score = rev.score
	if score > 0 then
		score = "+" .. score
	end
	local str = nil
	local colorScore = newColorByString("33FF38")
	self.txtLiansheng.color = colorScore
	if rev.WinNum < 0 then
		str = "连败"
		self.txtLiansheng.color = newColorByString("FF0000")
	elseif rev.WinNum > 0 then
		str = "连胜"
	end
	self.txtJifenAdd.text = score
	local tmpFlag = 0
	
	if rev.score < 0 then
		tmpFlag = 1
		colorScore = newColorByString("FF0000")
	end
	self.txtJifenAdd.color = colorScore
	local url = StringFormat("Icon/Other/arrow_{0}1", tmpFlag)
	if rev.score == 0 then
		self.iconJifenFlag.visible = false
	else
		self.iconJifenFlag.visible = true
		self.iconJifenFlag.icon = url
	end
	if str then
		self.txtLiansheng.visible = true
		self.txtLiansheng.text = math.abs(rev.WinNum) .. str
	else
		self.txtLiansheng.visible = false
	end

	self:DestroyAwardIcons()
	self.awardIcons = {}
	local conn = self.awardContainer
	if conn.numChildren ~= 0 then
		conn:RemoveChildren(0, -1, true)
	end
	if rev.rewards then
		for i, v in ipairs(rev.rewards) do
			--self:CreateAwardIcon(conn, i*90, 10, GoodsVo.GetIconUrl(v.goodsType, v.itemId), GoodsVo.GetRare(v.goodsType, v.itemId), v.num)
			local icon = PkgCell.New(conn)
			icon:SetXY(i*90, 10)
			icon:OpenTips(true)
			icon:SetDataByCfg(tonumber(v.goodsType), tonumber(v.itemId), tonumber(v.num), false)
			table.insert(self.awardIcons, icon)
		end
	end

	--激活的时候开始倒计时
	self.victory.visible = result == 0
	self.defeated.visible = result == 1

	destroyTime = destroyTime or 30000
	local time = destroyTime / 1000
	self.timerId= nil
	if result == 2 then
		self:ShowTimeEndFlag()
	end
end

function PoPFinishTianti:__delete()
	self.victoryBg = nil
	self.vRole3D = nil
	self.n2 = nil
	self.victoryText = nil
	self.victory = nil
	self.defeatedBg = nil
	self.dRole3D = nil
	self.n11 = nil
	self.n12 = nil
	self.victoryText_2 = nil
	self.defeated = nil
	self:DestroyAwardIcons()
	RenderMgr.Remove(self.timerId)
end

function PoPFinishTianti:ShowTimeEndFlag()
	local timeIn, timeStay, timeOut = 1, 2.5, 1
	if not self.imgTimeOut then return end
	self.imgTimeOut.visible = true
	self.imgTimeOut.alpha = 0
	local t1 = self.imgTimeOut:TweenFade(1, timeIn)
	local function fadeOut()
		local t2 = self.imgTimeOut:TweenFade(0, timeOut)
		TweenUtils.OnComplete(t2, function ( obj )
			self.imgTimeOut.visible = false
		end, self)
	end
	TweenUtils.OnComplete(t1, function ( obj )
		DelayCall(fadeOut, timeStay)
	end, self)
end

function PoPFinishTianti:CreateAwardIcon(conn, x, y, res, rare, num)
	local ui = UIPackage.CreateObject("Common" , "AwardIcon")
	conn:AddChild(ui)
	ui.x = x
	ui.y = y
	ui.icon = res
	ui:GetChild("bg").url = "Icon/Common/grid_cell_"..(rare or 0)
	ui:GetChild("title").text = num or 1
	return ui
end