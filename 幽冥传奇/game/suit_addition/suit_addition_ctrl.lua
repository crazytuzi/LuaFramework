require("scripts/game/suit_addition/suit_addition_data")
require("scripts/game/suit_addition/suit_addition_view")

SuitAdditionCtrl = SuitAdditionCtrl or BaseClass(BaseController)

function SuitAdditionCtrl:__init()
    if SuitAdditionCtrl.Instance then
        ErrorLog("[SuitAdditionData]:Attempt to create singleton twice!")
    end

    SuitAdditionCtrl.Instance = self

    self.data = SuitAdditionData.New()
    self.view = SuitAdditionView.New(ViewName.SuitAddition)

    GlobalEventSystem:Bind(OtherEventType.STRENGTH_INFO_CHANGE, BindTool.Bind(self.OnStrengthChange, self))
    GlobalEventSystem:Bind(OtherEventType.XUELIAN_INFO_CHANGE, BindTool.Bind(self.OnStrengthChange, self))
	GlobalEventSystem:Bind(OtherEventType.MOLDINGSOUL_INFO_CHANGE, BindTool.Bind(self.OnStrengthChange, self))
	GlobalEventSystem:Bind(OtherEventType.APOTHEOSIS_INFO_CHANGE, BindTool.Bind(self.OnStrengthChange, self))
	GlobalEventSystem:Bind(OtherEventType.STONE_INLAY_INFO_CHANGE, BindTool.Bind(self.OnStrengthChange, self))
end

function SuitAdditionCtrl:__delete()
    SuitAdditionCtrl.Instance = nil
end

function SuitAdditionCtrl:OnStrengthChange()
    self.view:Flush()
end