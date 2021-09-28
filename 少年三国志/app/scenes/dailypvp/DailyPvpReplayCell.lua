local DailyPvpReplayCell = class ("DailyPvpReplayCell", function (  )
	return CCSItemCellBase:create("ui_layout/dailypvp_ReplayCell.json")
end)

function DailyPvpReplayCell:ctor(list, index)
    self._leftTitle = self:getImageViewByName("Image_title1")
    self._rightTitle = self:getImageViewByName("Image_title2")
    self._leftDi = self:getImageViewByName("Image_di1")
    self._rightDi = self:getImageViewByName("Image_di2")

    self:registerBtnClickEvent("Button_play", function ( widget)
        uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpBattleScene").new(self._data,{isReplay=true,score=0,honor=0,double=false}))
    end)
end

function DailyPvpReplayCell:updateData(data)
    self._data = data

    local isTeam1 = self:isTeam1(data)
    local members = isTeam1 and {data.team1_members,data.team2_members} or {data.team2_members,data.team1_members}
    local isWin = (isTeam1 and data.team1_win) or (not isTeam1 and not data.team1_win)
    for i = 1 , 2 do 
        for k , v in pairs(members[i]) do 
            self:getLabelByName("Label_hero"..i.."_"..(v.sp3+1)):setText(v.name)
        end
    end
    
    self._leftTitle:loadTexture(isWin and "ui/text/txt/jzhlg_shengli.png" or "ui/text/txt/jzhlg_shibai.png")
    self._rightTitle:loadTexture(isWin and "ui/text/txt/jzhlg_shibai.png" or "ui/text/txt/jzhlg_shengli.png")
    self._leftDi:setColor(isWin and Colors.PVP_WIN or Colors.PVP_LOSE)
    self._rightDi:setColor(isWin and Colors.PVP_LOSE or Colors.PVP_WIN)
end

function DailyPvpReplayCell:isTeam1(data)
    local isTeam1 = false
    for k , v in pairs(data.team1_members) do 
        if v.id == G_Me.userData.id and tostring(v.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
            isTeam1 = true
        end
    end
    return isTeam1
end

return DailyPvpReplayCell