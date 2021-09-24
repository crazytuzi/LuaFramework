local SkillLayerMediator = classGc(mediator, function(self, _view)
    self.name = "SkillLayerMediator"
    self.view = _view

    self:regSelf()
end)


SkillLayerMediator.protocolsList={
	_G.Msg["ACK_SKILL_LIST"],
}
    
SkillLayerMediator.commandsList={
    CSkillDataUpdateCommand.TYPE
}

function SkillLayerMediator.getView(self)
    return self.view
end

function SkillLayerMediator.processCommand( self, _command )
    if _command:getType() == CSkillDataUpdateCommand.TYPE then
        print("###$#%")
        local curScenesType = _G.g_Stage :getScenesType()
        if curScenesType== _G.Const.CONST_MAP_TYPE_CITY then
            
            if _command :getData() == CSkillDataUpdateCommand.TYPE_UPDATE then
                self :getView() : updateSkillData()
                _G.Util:playAudioEffect("ui_skill_upgrade")
                -- self :getView() : updateSkillInfo()
                self :getView() : updateSkillBtnList()
            elseif _command :getData() == CSkillDataUpdateCommand.TYPE_EQUIP then
                self :getView() : updateSkillData()
                self :getView() : updateSkillEquip()
                -- self :getView() : updateSkillBtnList()
            end
            print("skill getData()", _command :getData())
        end
    end
end

function SkillLayerMediator.ACK_SKILL_LIST(self,_ackMsg)
	print("<<<<<<<<<<<<<<<<<人物>>>>>>>>>>>>>>>>>>")
	self :getView() : updateSkillData()
    self.view:updateSkillBtnList()
end

return SkillLayerMediator