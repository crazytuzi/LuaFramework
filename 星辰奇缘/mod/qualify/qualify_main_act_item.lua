QualifyMainActItem = QualifyMainActItem or BaseClass()

function QualifyMainActItem:__init(gameObject, args)
    self.gameObject = gameObject
    self.data = nil
    self.args = args

    self.transform = self.gameObject.transform

    self.TxtDesc = self.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.msg = MsgItemExt.New(self.TxtDesc, 340, 16, 23)
    -- args.item_index
end

function QualifyMainActItem:Release()

end

function QualifyMainActItem:Refresh(args)

end

function QualifyMainActItem:InitPanel(_data)
    self.data = _data
    -- self.TxtDesc.text = _data.data.msg
    self.msg:SetData(QuestEumn.FilterContent(_data.data.msg))
end