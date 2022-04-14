--
-- @Author: chk
-- @Date:   2018-09-14 15:58:41
--
EquipEvent = EquipEvent or {
	PhaseChange       = "EquipEvent.PhaseChange",      --强化段位改变
	StoneChange       = "EquipEvent.StoneChange",      --镶嵌宝石改变
	TakeOffStone      = "EquipEvent.TakeOffStone",     --卸下宝石
	MountStoneItemPos = "EquipEvent.MountStoneItemPos",
	DestroyStoneOperationItem = "EquipEvent.DestroyStoneOperationItem",
	CloseStoneOperateView = "EquipEvent.CloseStoneOperateView", --关闭宝石操作表
	--StoneAttrChange   = "EquipEvent.StoneAttrChange",  --宝石属性改变
	ShowStoneViewInfo = "EquipEvent.ShowStoneViewInfo", --显示宝石界面信息
	RequestEquipList  = "EquipEvent.RequestEquipList", --请求装备列表
	PutOnEquip        = "EquipEvent.PutOnEquip",       --穿上装备
	PutOnEquipSucess  = "EquipEvent.PutOnEquipSucess", --穿上装备成功
	PutOffEquip       = "EquipEvent.PutOffEquip",      --卸下装备
	StrongItemPos     = "EquipEvent.StrongItemPos",    --通知强化
	ShowEquipUpPanel  = "EquipEvent.ShowEquipPanel",   --显示装备升级界面
	ShowStrongInfo    = "EquipEvent.ShowStrongInfo",   --显示强化信息
	StrongSucess      = "EquipEvent.StrongSucess",     --强化成功
	StrongFail        = "EquipEvent.StrongFail",
	StrongBless       = "EquipEvent.StrongBless",
	ShowSuitAttr       = "EquipEvent.ShowSuitAttr",      --显示强化套装属性
	UpdateEquipDetail = "EquipEvent.UpdateEquipDetail", --更新装备详细信息
    ShowEquipCombinePanel = "EquipEvent.ShowEquipCombinePanel", --打开装备合成界面
	ShowSuitViewInfo = "EquipEvent.ShowSuitViewInfo",    --显示套装界面信息
	ShowSuiteDesc    = "EquipEvent.ShowSuiteDesc",       --无法打造套装时显示信息
	SuitItemPos = "EquipEvent.SuitItemPos",
	SuitList = "EquipEvent.SuitList",
	BuildSuitSucess = "EquipEvent.BuildSuitSucess",     --打造成功
	SelectDefaultSuit = "EquipEvent.SelectDefaultSuit",
	BrocastSetViewPosition   = "EquipEvent.BrocastSetViewPosition",   --
	CloseStoneOperationView  = "EquipEvent.CloseStoneOperationView",
	UpdateSmeltInfo          = "EquipEvent.UpdateSmeltInfo",  --更新熔炼信息
	SmeltSuccess             = "EquipEvent.SmeltSuccess",     --熔炼成功 
	SelectEquipItem          = "EquipEvent.SelectEquipItem",  --选择装备
	SelectCastItem           = "EquipEvent.SelectCastItem",   --铸造装备选择
	EquipCastSuccess         = "EquipEvent.EquipCastSuccess", --铸造成功
	SelectRefineItem         = "EquipEvent.SelectRefineItem", --选择洗练装备
	UpdateRefineInfo         = "EquipEvent.UpdateRefineInfo", --更新洗练信息
	SelectRefineMateria      = "EquipEvent.SelectRefineMateria", --选择材料

	EquipStrongAll           = "EquipEvent.EquipStrongAll",   --一键强化事件
	EquipStrongSuite         = "EquipEvent.EquipStrongSuite",  --套装强化成功
}
