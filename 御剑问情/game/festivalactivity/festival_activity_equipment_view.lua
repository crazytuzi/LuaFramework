FestivalequipmentInfoView = FestivalequipmentInfoView or BaseClass(BaseView)

function FestivalequipmentInfoView:__init()
	self.ui_config = {"uis/views/festivalactivity/autumn_prefab", "JieRiZhuangBeiInfo"}
	self.view_layer = UiLayer.Pop
	self.list_info = {}
	self.seq = 0
end

function FestivalequipmentInfoView:__delete()
	self.list_info = {}
end

function FestivalequipmentInfoView:ReleaseCallBack()
	self.num = nil
	self.shengmi = nil
	self.gongji = nil
	self.fangyu = nil
	self.mingzhong = nil
	self.shanbi = nil
	self.baoji = nil
	self.jianren = nil
	self.zhanli = nil
end

function FestivalequipmentInfoView:CloseWindow()
	self:Close()
end

function FestivalequipmentInfoView:LoadCallBack()
	self.num = self:FindVariable("num")
	self.shengmi = self:FindVariable("shengmi")
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.mingzhong = self:FindVariable("mingzhong")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.jianren = self:FindVariable("jianren")
	self.zhanli = self:FindVariable("zhanli")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function FestivalequipmentInfoView:OpenCallBack()
	self:Flush()
end

function FestivalequipmentInfoView:OnFlush()
	self.list_info = FestivalActivityData.Instance:GetEquipmentInfo()
	if nil == self.list_info or nil == next(self.list_info) then
		return
	end
	local zhanli_info = {}
	zhanli_info.max_hp = self.list_info.hp or 0
	zhanli_info.gong_ji = self.list_info.gongji or 0
	zhanli_info.fang_yu = self.list_info.fangyu or 0
	zhanli_info.ming_zhong = self.list_info.mingzhong or 0
	zhanli_info.shan_bi = self.list_info.shanbi or 0
	zhanli_info.bao_ji = self.list_info.baoji or 0
	zhanli_info.jian_ren = self.list_info.jianren or 0


	if self.seq == 5 then
		self.num:SetValue(string.format(Language.Activity.TaoZhuangInfo1, self.seq))
	else
		self.num:SetValue(string.format(Language.Activity.TaoZhuangInfo2, self.seq))
	end

	self.shengmi:SetValue(self.list_info.hp)
	self.gongji:SetValue(self.list_info.gongji)
	self.fangyu:SetValue(self.list_info.fangyu)
	self.mingzhong:SetValue(self.list_info.mingzhong)
	self.shanbi:SetValue(self.list_info.shanbi)
	self.baoji:SetValue(self.list_info.baoji)
	self.jianren:SetValue(self.list_info.jianren)
	self.zhanli:SetValue(CommonDataManager.GetCapability(zhanli_info))
end

function FestivalequipmentInfoView:SendEquipSeq(seq)
	self.seq = seq or 0
end