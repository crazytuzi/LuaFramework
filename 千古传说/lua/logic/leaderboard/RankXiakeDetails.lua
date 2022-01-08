
local RankXiakeDetails = class("RankXiakeDetails")


function RankXiakeDetails:ctor(data)

end

function RankXiakeDetails:initUI(ui,layer)

    self.layer = layer
    --侠客榜个人信息
    self.bgXiakebang = TFDirector:getChildByPath(ui, "bgXiakebang")
    self.txt_xiakepaiming_word = TFDirector:getChildByPath(self.bgXiakebang, "txt_xiakepaiming_word")
    self.txtXKZhandouli = TFDirector:getChildByPath(self.bgXiakebang, "txtXKZhandouli")
    self.img_pinzhiditu = TFDirector:getChildByPath(self.bgXiakebang, "img_pinzhiditu")
    self.img_touxiang = TFDirector:getChildByPath(self.img_pinzhiditu, "img_touxiang")
    self.txt_lv_word = TFDirector:getChildByPath(self.img_pinzhiditu, "txt_lv_word")
    self.img_zhiye = TFDirector:getChildByPath(self.img_pinzhiditu, "img_zhiye")

    self.bgLeft1 = TFDirector:getChildByPath(ui, "bgLeft1")
    self.Panel_Role = TFDirector:getChildByPath(ui, "Panel_Role")
    self.txtName = TFDirector:getChildByPath(ui, "txtName")
    self.txtlv = TFDirector:getChildByPath(ui, "txtlv")
    self.txt_power = TFDirector:getChildByPath(self.bgLeft1, "txt_power")
    self.teamPanel = TFDirector:getChildByPath(ui, "Panel_Role"..5)
    self.img_fightpower = TFDirector:getChildByPath(self.bgLeft1, "img_fightpower")
    self.img_ditu = TFDirector:getChildByPath(self.bgLeft1, "img_ditu")
    self.img_headIcon = TFDirector:getChildByPath(self.bgLeft1, "img_head")
    self.img_headIcon:setFlipX(true)
    self.img_Frame = TFDirector:getChildByPath(self.bgLeft1, "bg_touxiang")
    self.img_namebg = TFDirector:getChildByPath(self.bgLeft1, "bg_name")
    self.btn_team1 = TFDirector:getChildByPath(self.bgLeft1, "btn_team1")
    self.btn_team2 = TFDirector:getChildByPath(self.bgLeft1, "btn_team2")
    --未获得排名
    self.bgXiakebangNo = TFDirector:getChildByPath(ui, "bgXiakebangNo")
    self.txtXKPower = TFDirector:getChildByPath(self.bgXiakebangNo, "txtXKZhandouli")
    self.img_pinzhidituNo = TFDirector:getChildByPath(self.bgXiakebangNo, "img_pinzhiditu")
    self.img_touxiangNo = TFDirector:getChildByPath(self.img_pinzhidituNo, "img_touxiang")
    self.txt_lv_wordNo = TFDirector:getChildByPath(self.img_pinzhidituNo, "txt_lv_word")
    self.img_zhiyeNo = TFDirector:getChildByPath(self.img_pinzhidituNo, "img_zhiye")
    self.bgExNo = TFDirector:getChildByPath(self.bgXiakebangNo, "bgEx")
    self.txtPowerNo = TFDirector:getChildByPath(self.bgExNo, "txtPower")
    
    self.teamRole = nil
end

function RankXiakeDetails:showDetails(item)

    if self.teamRole ~= nil then
        self.teamRole:removeMEListener(TFWIDGET_CLICK)
        self.teamPanel:removeChild(self.teamRole)           
        self.teamRole = nil
    end

    if item ~= nil then
        self.txtName:setVisible(true)
        self.txtlv:setVisible(true)
        self.txt_power:setVisible(true)
        self.img_fightpower:setVisible(true)
        self.img_ditu:setVisible(true)
        self.img_headIcon:setVisible(true)
        self.img_Frame:setVisible(true)
        self.img_namebg:setVisible(true)
        self.btn_team1:setVisible(false)
        self.btn_team2:setVisible(false)
        self.txtName:setString(item.name)
        local roleConfig = RoleData:objectByID(item.profession)                     --pck change head icon and head icon frame
        if nil == roleConfig then
            roleConfig = RoleData:objectByID(item.roleId)
        end
        self.img_headIcon:setTexture(roleConfig:getIconPath())
        Public:addFrameImg(self.img_headIcon,item.headPicFrame)                    --end
        Public:addInfoListen(self.img_headIcon,true,1,item.playerId)
        self.txtlv:setString("")
        self.txt_power:setText(item.value)

        self.teamRole = GameResourceManager:getRoleAniById(item.roleId)
        self.teamRole:setPosition(ccp(0,0))
        self.teamPanel:addChild(self.teamRole)
        self.teamRole:play("stand", -1, -1, 1)
        self.teamRole:setScale(1.2)
        self.layer:SaveRoleID(item.roleId)

        self.teamRole.logic = self
        self.teamRole.roleId = item.instanceId
        self.teamRole.playerId = item.playerId
        --self.teamRole.playerName = item.name
        self.teamRole.item = item
        self.teamRole:setTouchEnabled(true)
        self.teamRole:addMEListener(TFWIDGET_CLICK, audioClickfun(self.openOtherRoleInfo), 1);
    end
end

function RankXiakeDetails:showMyDetails(item)

    local cardRole = CardRoleManager:getRoleById( item.topRoleId )

    if cardRole == nil then
        self.layer:refreshDataOfRank()
        return
    end

    --print(cardRole.power)

    local roleIcon = RoleData:objectByID(item.topRoleId)

    if item.myRanking == 0 then
        self.bgXiakebang:setVisible(false)
        self.bgXiakebangNo:setVisible(true)
        local powerNum = item.lastValue - item.myBestValue
        --self.txtPowerNo:setString(powerNum.."战斗力")
        self.txtPowerNo:setString(stringUtils.format(localizable.common_ce2, powerNum))
        self.txtXKPower:setString(item.myBestValue)
        self.img_pinzhidituNo:setTexture(GetColorIconByQuality(cardRole.quality));
        -- self.img_pinzhidituNo:setTexture(GetRoleBgByWuXueLevel(cardRole.martialLevel));
        self.img_touxiangNo:setTexture(roleIcon:getIconPath())
        self.img_zhiyeNo:setTexture("ui_new/fight/zhiye_".. roleIcon.outline ..".png")
        self.txt_lv_wordNo:setText(cardRole.level)
    else
        self.bgXiakebang:setVisible(true)
        self.bgXiakebangNo:setVisible(false)
        self.img_pinzhiditu:setVisible(true)
        self.txt_xiakepaiming_word:setText(item.myRanking)
        self.txtXKZhandouli:setText(item.myBestValue)
        self.img_pinzhiditu:setTexture(GetColorIconByQuality(cardRole.quality));
        -- self.img_pinzhiditu:setTexture(GetRoleBgByWuXueLevel(cardRole.martialLevel))
        self.img_touxiang:setTexture(roleIcon:getIconPath())
        self.txt_lv_word:setText(cardRole.level)
        self.img_zhiye:setTexture("ui_new/fight/zhiye_".. roleIcon.outline ..".png")
    end
end

function RankXiakeDetails:setVisible(enable)
	self.bgXiakebang:setVisible(enable)
	self.bgLeft1:setVisible(enable)
    self.bgXiakebangNo:setVisible(enable)

    if enable == true then
        self:registerEvents()
    else
        self:removeEvents()
        self:removeRoleAnim()
    end
end

function RankXiakeDetails.openOtherRoleInfo(sender)
    
    RankManager:requestRoleDataById( sender.playerId, sender.roleId, sender.item )
end

function RankXiakeDetails:registerEvents()
 
end

function RankXiakeDetails:removeEvents()
   
end

function RankXiakeDetails:removeRoleAnim()

    if self.teamRole ~= nil then
        self.teamRole:removeMEListener(TFWIDGET_CLICK)
        self.teamPanel:removeChild(self.teamRole)           
        self.teamRole = nil
    end
end
return RankXiakeDetails