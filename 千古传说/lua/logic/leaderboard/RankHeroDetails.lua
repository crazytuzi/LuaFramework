
local RankHeroDetails = class("RankHeroDetails")


function RankHeroDetails:ctor(data)

end

function RankHeroDetails:initUI( ui ,rank_type, layer)

    --群豪、英雄、无量
    self.currTeamIndex = 1
    self.type = rank_type
    self.layer = layer
    self.bgLeft1 = TFDirector:getChildByPath(ui, "bgLeft1")
    self.Panel_Role = TFDirector:getChildByPath(ui, "Panel_Role")
    self.txtName = TFDirector:getChildByPath(ui, "txtName")
    self.txtlv = TFDirector:getChildByPath(ui, "txtlv")
    self.txt_power = TFDirector:getChildByPath(self.bgLeft1, "txt_power")
    self.img_fightpower = TFDirector:getChildByPath(self.bgLeft1, "img_fightpower")
    self.img_ditu = TFDirector:getChildByPath(self.bgLeft1, "img_ditu")
    self.img_headIcon = TFDirector:getChildByPath(self.bgLeft1, "img_head")
    self.img_headIcon:setFlipX(true)
    self.img_Frame = TFDirector:getChildByPath(self.bgLeft1, "bg_touxiang")
    self.img_namebg = TFDirector:getChildByPath(self.bgLeft1, "bg_name")
    self.btn_team1 = TFDirector:getChildByPath(self.bgLeft1, "btn_team1")
    self.btn_team2 = TFDirector:getChildByPath(self.bgLeft1, "btn_team2")
    --布阵详细信息
    self.Team_Panel = {}
    self.Team_Role = {}
    for i=1,9 do
        self.Team_Panel[i] = TFDirector:getChildByPath(ui, "Panel_Role"..i)
        self.Team_Role[i] = nil
    end

    --未入榜的显示
    self.bgMyPaimingEx = TFDirector:getChildByPath(ui, "bgMyPaimingEx")
    self.txtWdpmEx = TFDirector:getChildByPath(self.bgMyPaimingEx, "txtWdpm")
    self.txtPowerEx =  TFDirector:getChildByPath(self.bgMyPaimingEx, "txtPower")
    self.txtZhandouliEx = TFDirector:getChildByPath(self.bgMyPaimingEx, "txtZhandouli")
    self.txtZdlEx = TFDirector:getChildByPath(self.bgMyPaimingEx, "txtZdl")

    self.bgMyPaimingNo = TFDirector:getChildByPath(ui, "bgMyPaimingNo")
    self.txtWdpmExNo = TFDirector:getChildByPath(self.bgMyPaimingNo, "txtWdpm")

    

    --群豪、英雄、无量三榜的个人信息
    self.bgMyPaiming = TFDirector:getChildByPath(ui, "bgMyPaiming")
    self.txtWdpm = TFDirector:getChildByPath(ui, "txtWdpm")
    self.paiming = TFDirector:getChildByPath(ui, "paiming")
    self.txtCengshu = TFDirector:getChildByPath(ui, "txtCengshu")
    self.txtZdl = TFDirector:getChildByPath(self.bgMyPaiming, "txtZdl")
    self.txtZhandouli = TFDirector:getChildByPath(ui, "txtZhandouli")
    self.Image_LeaderboardNEW_1 = TFDirector:getChildByPath(ui, "Image_LeaderboardNEW_1")
    self.Img_chenhao_Textures = {
        'ui_new/leaderboard/n1.png',
        'ui_new/leaderboard/n2.png',
        'ui_new/leaderboard/n3.png',
        'ui_new/leaderboard/n4.png',
        'ui_new/leaderboard/n5.png',
        'ui_new/leaderboard/n6.png',
        'ui_new/leaderboard/n7.png',
        'ui_new/leaderboard/n8.png',
        'ui_new/leaderboard/n9.png',
        'ui_new/leaderboard/n10.png'}

    self.registerEnable = false
end


function RankHeroDetails:setDefault()

    self.bgLeft1:setVisible(true)
    self.txtName:setVisible(false)
    self.txtlv:setVisible(false)
    self.txt_power:setVisible(false)
    self.img_fightpower:setVisible(false)
    self.img_ditu:setVisible(false)
    self.img_headIcon:setVisible(false)
    self.img_Frame:setVisible(false)
    self.img_namebg:setVisible(false)
    self.btn_team1:setVisible(false)
    self.btn_team2:setVisible(false)
end

function RankHeroDetails:showDetails(item)
    self:removeRoleAnim()
    self.item = item
    self.currTeamIndex = 1
    local TeamTable = item.formation
    self.roleIdTable = {}

    if TeamTable ~= nil then
        self.bgLeft1:setVisible(true)
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
        local roleConfig = RoleData:objectByID(item.profession)                     --pck change head icon and head icon frame
        if nil == roleConfig then
            roleConfig = RoleData:objectByID(item.roleId)
        end
        self.img_headIcon:setTexture(roleConfig:getIconPath())
        Public:addFrameImg(self.img_headIcon,item.headPicFrame)                    --end
        Public:addInfoListen(self.img_headIcon,true,1,item.playerId)
        self.txtName:setString(item.name)
        if self.layer.btn_curr_type == RankListType.Rank_List_Qunhao then
            local percentValue
            if item.totalChallenge == 0 then
                --percentValue = "胜率: 0%"
                percentValue = stringUtils.format(localizable.common_win_radio,0)
            else
                --percentValue = string.format("胜率:%d ", (item.totalWin*100)/item.totalChallenge) .. "%"
                local _num = math.ceil((item.totalWin*100)/item.totalChallenge)
                percentValue = stringUtils.format(localizable.common_win_radio,_num)
            end
            self.txtlv:setString(percentValue)
        else

            --self.txtlv:setString(item.level.."级")
            self.txtlv:setString(stringUtils.format(localizable.common_LV,item.level))
        end

        self.img_fightpower:setVisible(true)
        self.txt_power:setVisible(true)
        self.img_ditu:setVisible(true)

        if self.currTeamIndex == 1 then
            self.txt_power:setText(item.power)
        else
            self.txt_power:setText(item.secondPower)
        end
        self:showFormation(TeamTable)
        --self:brushTeamBtn(1)
        if item.secondFormation ~= nil then
            self:brushTeamBtn(1)
        end
    end
end

function RankHeroDetails:OnShowTeamClick(sender)
    local TeamTable = self.item.formation
    self.currTeamIndex = sender.id
    self.txt_power:setText(self.item.power)
    if sender.id == 2 then
        TeamTable = self.item.secondFormation
        self.txt_power:setText(self.item.secondPower)
    end
    self:brushTeamBtn(sender.id)
    self:removeRoleAnim()
    self:showFormation(TeamTable)

    print('self.currTeamIndex = ',self.currTeamIndex)
end

function RankHeroDetails:showFormation( TeamTable )
    if TeamTable ~= nil then
        for k,v in pairs(TeamTable) do
            local position = v.position + 1
            self.Team_Role[position] = GameResourceManager:getRoleAniById(v.templateId)
            self.Team_Role[position].StorageRoleID = v.templateId
            self.Team_Role[position]:setPosition(ccp(0,0))
            self.Team_Panel[position]:addChild(self.Team_Role[position])
            self.Team_Role[position]:play("stand", -1, -1, 1)
            self.Team_Role[position]:setScale(0.9)
            self.layer:SaveRoleID(v.templateId)

            self.Team_Role[position].logic = self
            self.Team_Role[position].ID = v.templateId
            self.Team_Role[position].PlayerID = self.item.playerId
            self.Team_Role[position].playerName = self.item.name
            self.Team_Role[position]:setTouchEnabled(true)
            self.Team_Role[position]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.openOtherRoleInfo), 1);

            if self.roleIdTable[self.currTeamIndex] == nil then
                self.roleIdTable[self.currTeamIndex] = {}
            end
            local newIndex = #self.roleIdTable[self.currTeamIndex] + 1
            self.roleIdTable[self.currTeamIndex][newIndex] = v.templateId
        end
    end
end

function RankHeroDetails:brushTeamBtn(id)
    self.btn_team1:setVisible(true)
    self.btn_team2:setVisible(true)
    if id == 1 then
        self.btn_team1:setTouchEnabled(false)
        self.btn_team2:setTouchEnabled(true)
        self.btn_team1:setTextureNormal("ui_new/leaderboard/btn_team1s.png")
        self.btn_team2:setTextureNormal("ui_new/leaderboard/btn_team2.png")
    else
        self.btn_team1:setTouchEnabled(true)
        self.btn_team2:setTouchEnabled(false)
        self.btn_team1:setTextureNormal("ui_new/leaderboard/btn_team1.png")
        self.btn_team2:setTextureNormal("ui_new/leaderboard/btn_team2s.png")
    end
end

function RankHeroDetails:showMyDetails(item)

    local powerDx;
    --self.txtZdlEx:setText("战斗力:")
    self.txtZdlEx:setText(localizable.common_ce_text)
    --self.txtZdl:setText("战斗力:")
    self.txtZdl:setText(localizable.common_ce_text)
    if self.layer.btn_curr_type == RankListType.Rank_List_Hero then
        self.txtCengshu:setVisible(false)
        self.txtZdl:setVisible(true)
        self.txtZhandouli:setVisible(true)        
        self.txtZhandouli:setString(item.myBestValue)

        --powerDx = (item.lastPower - item.myBestValue).."战斗力"
        powerDx =  stringUtils.format(localizable.common_ce2,  (item.lastPower - item.myBestValue))
    elseif self.layer.btn_curr_type == RankListType.Rank_List_Qunhao then
        self.txtCengshu:setVisible(false)
        self.txtZdl:setVisible(true)
        self.txtZhandouli:setVisible(true)
        self.txtZhandouli:setString(StrategyManager:getPower())
        --powerDx = (item.myBestValue-item.lastValue).."名"
        powerDx =stringUtils.format(localizable.common_rank, (item.myBestValue-item.lastValue))
        
    elseif self.layer.btn_curr_type == RankListType.Rank_List_fumo then  
        --self.txtZdlEx:setText("最高伤害:")
        --self.txtZdl:setText("最高伤害:")
        self.txtZdlEx:setText(localizable.common_max_hurt)
        self.txtZdl:setText(localizable.common_max_hurt)
        self.txtCengshu:setVisible(false)
        self.txtZdl:setVisible(true)
        self.txtZhandouli:setVisible(true)
        self.txtZhandouli:setString(item.myBestValue)
        --powerDx = (item.last - item.myBestValue).."伤害"     
	powerDx =stringUtils.format(localizable.common_hurt, (item.last - item.myBestValue))
    elseif self.layer.btn_curr_type == RankListType.Rank_List_ShaLu then  
        --self.txtZdlEx:setText("杀戮值:")
        --self.txtZdl:setText("杀戮值:")
	self.txtZdlEx:setText(localizable.common_max_shalu)
        self.txtZdl:setText(localizable.common_max_shalu)
        self.txtCengshu:setVisible(false)
        self.txtZdl:setVisible(true)
        self.txtZhandouli:setVisible(true)
        self.txtZhandouli:setString(item.myBestValue)
        --powerDx = (item.lastValue - item.myBestValue).."杀戮值"
	powerDx = stringUtils.format(localizable.common_shalu, item.lastValue - item.myBestValue)
    else
        self.txtCengshu:setVisible(true)
        self.txtZdl:setVisible(false)
        self.txtZhandouli:setVisible(false)
        --self.txtCengshu:setString(item.myBestValue.."层")
        self.txtCengshu:setString(stringUtils.format(localizable.common_ceng, item.myBestValue))
        --powerDx = (item.lastValue - item.myBestValue).."层"
        powerDx = stringUtils.format(localizable.common_ceng, (item.lastValue - item.myBestValue))
    end


    self.bgMyPaimingNo:setVisible(false)
    if item.myRanking == 0 then
        self.bgMyPaiming:setVisible(false)
        if self.layer.btn_curr_type == RankListType.Rank_List_Qunhao or self.layer.btn_curr_type == RankListType.Rank_List_Wuliang then
            self.bgMyPaimingNo:setVisible(true)
            self.bgMyPaimingEx:setVisible(false)
            --self.txtWdpmExNo:setText("未排名")
            self.txtWdpmExNo:setText(localizable.common_not_rank)
        elseif self.layer.btn_curr_type == RankListType.Rank_List_fumo and item.myBestValue == 0 then
            self.bgMyPaimingNo:setVisible(true)
            self.bgMyPaimingEx:setVisible(false)
            --self.txtWdpmExNo:setText("未挑战")
            self.txtWdpmExNo:setText(localizable.common_not_fight)
        else
            self.bgMyPaiming:setVisible(false)
            self.bgMyPaimingEx:setVisible(true)
            self.txtPowerEx:setString(powerDx)
            self.txtZhandouliEx:setString(item.myBestValue)
        end
    else
        self.bgMyPaiming:setVisible(true)
        self.bgMyPaimingEx:setVisible(false)
        self.paiming:setVisible(true)
        self.paiming:setText(item.myRanking)

        local rankingHero = RankManager:isInTen(MainPlayer:getPlayerId())
        if rankingHero > 10 then
            self.Image_LeaderboardNEW_1:setVisible(false)
        else
            self.Image_LeaderboardNEW_1:setVisible(true)
            self.Image_LeaderboardNEW_1:setTexture(self.Img_chenhao_Textures[rankingHero])
        end
   end
end

function RankHeroDetails:setVisible(enable)
	self.bgMyPaiming:setVisible(enable)
	self.bgLeft1:setVisible(enable)
    self.bgMyPaimingEx:setVisible(enable)
    self.bgMyPaimingNo:setVisible(enable)
    if enable == true then
        self:registerEvents()
    else
        self:removeEvents()
        self:removeRoleAnim()
    end    
end

function RankHeroDetails.openOtherRoleInfo(sender)

    local self = sender.logic
    sender.logic.clickRoleId = sender.ID
    sender.logic.playerName = sender.playerName

    if self.layer.btn_curr_type == RankListType.Rank_List_Qunhao then
        OtherPlayerManager:showOtherPlayerdetails(sender.PlayerID, "rank", true)
    elseif self.layer.btn_curr_type == RankListType.Rank_List_ShaLu then
        if self.currTeamIndex == 2 and self.item.secondPower ~= 0 then
            OtherPlayerManager:showOtherPlayerdetailsForShaluRank(sender.PlayerID, "rank", 4)
        else
            OtherPlayerManager:showOtherPlayerdetailsForShaluRank(sender.PlayerID, "rank", 3)
        end
    else
        OtherPlayerManager:showOtherPlayerdetails(sender.PlayerID, "rank")
    end
end

function RankHeroDetails:registerEvents()
    --监听点击英雄详情事件
    if self.registerEnable == false then
        self.registerEnable = true
        self.openRankInfolayer = function(event)
            if self.clickRoleId  ~= 0 then
                local userData = event.data[1];

                OtherPlayerManager:openRoleInfoByName( userData, self.clickRoleId, self.playerName, self.roleIdTable[self.currTeamIndex], teamIndex)
            end
        end
        TFDirector:addMEGlobalListener(OtherPlayerManager.OPENRANKINFO ,self.openRankInfolayer)
        self.btn_team1.id = 1
        self.btn_team2.id = 2
        self.btn_team1:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(RankHeroDetails.OnShowTeamClick,self)),1)
        self.btn_team2:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(RankHeroDetails.OnShowTeamClick,self)),1)
    end
end

function RankHeroDetails:removeEvents()
    if self.registerEnable then
        self.registerEnable = false
        TFDirector:removeMEGlobalListener(OtherPlayerManager.OPENRANKINFO ,self.openRankInfolayer)
    end
end

function RankHeroDetails:removeRoleAnim()

    for i=1,9 do
        if self.Team_Role[i] ~= nil then
            local StorageRoleID = self.Team_Role[i].StorageRoleID
            self.Team_Role[i]:removeMEListener(TFWIDGET_CLICK)
            self.Team_Role[i]:removeFromParent()            
            self.Team_Role[i] = nil
            GameResourceManager:deleRoleAniById(StorageRoleID)
        end
    end

end
return RankHeroDetails