require("scripts/game/diamond_pet/diamond_pet_data")
require("scripts/game/diamond_pet/diamond_pet_view")
require("scripts/game/diamond_pet/diamond_pet_open_box_view")
require("scripts/game/diamond_pet/excavate_boss_view")

--------------------------------------------------------
-- 钻石萌宠
--------------------------------------------------------

DiamondPetCtrl = DiamondPetCtrl or BaseClass(BaseController)

function DiamondPetCtrl:__init()
	if	DiamondPetCtrl.Instance then
		ErrorLog("[DiamondPetCtrl]:Attempt to create singleton twice!")
	end
	DiamondPetCtrl.Instance = self

	self.data = DiamondPetData.New()
	self.view = DiamondPetView.New(ViewDef.DiamondPet)
	self.open_box_view = DiamondPetOpenBoxView.New(ViewDef.DiamondPetOpenBox)

	self:RegisterAllProtocols()

	self.excavate_boss = {}
	self.is_excavating = false

	GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDelete, self))
end

function DiamondPetCtrl:__delete()
	DiamondPetCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.open_box_view then
		self.open_box_view:DeleteMe()
		self.open_box_view = nil
	end

	self:ReleaseExcavateBoss()
end

--登记所有协议
function DiamondPetCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDiamondPetData, "OnDiamondPetData")
end

----------接收----------

-- 接收钻石萌宠数据(0, 79)
function DiamondPetCtrl:OnDiamondPetData(protocol)
	local old_data = DiamondPetData.Instance:GetDiamondPetData()
	self.data:SetDiamondPetData(protocol)
	Scene.Instance:GetMainRole():RefreshAnimation()

	for k,v in pairs(self.excavate_boss) do
		v:Flush()
	end

	-- 钻石萌宠 显示已获得钻石数量
	if nil == self.today_diamond_text then
		local diamond_pet_icon = ViewManager.Instance:GetUiNode("MainUi", "iconbar", "DiamondPet")
		local parent = diamond_pet_icon:TextLayout()
		local text_node = XUI.CreateText(45, -5, 150, 30, cc.TEXT_ALIGNMENT_CENTER, "", COMMON_CONSTS.FONT, 18)
		parent:addChild(text_node, 999)
		XUI.EnableOutline(text_node)
		self.today_diamond_text = text_node
	end

	local cfg = DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	local pet_lv = protocol.pet_lv or 0
	local cur_cfg = cfg[pet_lv] or {}
	if next(cur_cfg) and self.today_diamond_text then
		local cur_diamond = protocol.today_diamond or 0
		local diamond_max = cur_cfg.diamondMax or 0
		local text = string.format("%d/%d", cur_diamond, diamond_max)
		local color = cur_diamond < diamond_max and COLOR3B.GREEN or COLOR3B.RED
		self.today_diamond_text:setString(text)
		self.today_diamond_text:setColor(color)
	end

	local rate_awards = cur_cfg.rateAwards or {}
	local award_index = protocol.award_index or 0
	local award = rate_awards[award_index] or {}
	local need_open_tip = award.tip
	if need_open_tip == 1 then
		local item_data= ItemData.InitItemDataByCfg(award)
		local reward_type = 1
		local need_check = false
		ExploreCtrl.Instance:OpenItemShow(item_data, reward_type, need_check)
	end
end

----------发送----------

-- 激活钻石萌宠(0, 22)
function DiamondPetCtrl.SendActivationDiamondPetReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSActivationDiamondPetReq)
	protocol:EncodeAndSend()
end

-- 挖掘怪物尸体(0, 23)
function DiamondPetCtrl.SendExcavateMonsterCorpseReq(obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExcavateMonsterCorpseReq)
	protocol.obj_id = obj_id
	protocol:EncodeAndSend()
end

-- 删除宝箱(8, 37)
function DiamondPetCtrl.SendDeleteBoxReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDeleteBox)
	protocol.series = series
	protocol:EncodeAndSend()
end

--------------------

function DiamondPetCtrl:OpenBox(data)
	self.series = data.series
	self.open_box_view:SetData(data)
	ViewManager.Instance:OpenViewByDef(ViewDef.DiamondPetOpenBox)
end

function DiamondPetCtrl:OnObjDelete(del_obj)
	local obj_id = del_obj.vo.obj_id or 0
	if self.excavate_boss[obj_id] then
		self.excavate_boss[obj_id]:DeleteMe()
		self.excavate_boss[obj_id] = nil
	end
end

function DiamondPetCtrl:OnExcavate()
	local obj_id = self.obj_id or 0
	if self.excavate_boss[obj_id] then
		self.excavate_boss[obj_id]:Excavate()
	end
end

function DiamondPetCtrl:ReleaseExcavateBoss()
	if next(self.excavate_boss) then
		for k,v in pairs(self.excavate_boss) do
			v:DeleteMe()
		end
	end
	self.excavate_boss = {}
end

function DiamondPetCtrl:GetExcavateBossList()
	return self.excavate_boss
end

function DiamondPetCtrl:SetObjId(obj_id)
	self.obj_id = obj_id
end

function DiamondPetCtrl:GotoExcavate()
	return nil ~= self.obj_id
end

function DiamondPetCtrl:SetExcavatState(bool)
	self.is_excavating = bool
end

function DiamondPetCtrl:IsExcavating()
	return self.is_excavating
end

function DiamondPetCtrl:StartFlyItem()
	if self.obj_id then
		self.excavate_boss[self.obj_id]:StartFlyItem()
	end
end
---------------------------------------------------
-- 主界面小部件-挖掘boss面板
---------------------------------------------------

function DiamondPetCtrl:InitExcavateBoss(obj)
	local obj_id = obj.vo.obj_id or 0

	if nil == self.excavate_boss[obj_id] then
		self.excavate_boss[obj_id] = ExcavateBossView.New(obj_id)
	end

	self.excavate_boss[obj_id]:Flush()
end

---------------------------------------------------
-- 试炼副本信息 end
---------------------------------------------------