--限时冲榜奖励排行列表非前三名Item
TimeLimitedRushRankItemTwo = TimeLimitedRushRankItemTwo or class("TimeLimitedRushRankItemTwo",BaseItem)

function TimeLimitedRushRankItemTwo:ctor(parent_node)
    self.abName = "timeLimitedRush"
    self.assetName = "TimeLimitedRushRankItemTwo"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    TimeLimitedRushRankItemTwo.Load(self)
end

function TimeLimitedRushRankItemTwo:dctor()
  
end

function TimeLimitedRushRankItemTwo:LoadCallBack(  )
    self.nodes = {
       "img_bg","txt_rank","txt_score","txt_name",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function TimeLimitedRushRankItemTwo:InitUI(  )
    self.img_bg = GetImage(self.img_bg)
    self.txt_name = GetText(self.txt_name)
    self.txt_score = GetText(self.txt_score)
    self.txt_rank = GetText(self.txt_rank)
end

function TimeLimitedRushRankItemTwo:AddEvent(  )
    
end

--data
function TimeLimitedRushRankItemTwo:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function TimeLimitedRushRankItemTwo:UpdateView()
    self.need_update_view = false

    local bg_index = 5
    if self.data.rank%2 == 0 then
        bg_index = 4
    end
    lua_resMgr:SetImageTexture(self,self.img_bg,"timelimitedrush_image","img_timeLimitedRush_rank_bg"..bg_index,true)


    self.txt_name.text = self.data.name
    self.txt_score.text = self.data.score
    self.txt_rank.text = self.data.rank

    local posY = (self.data.rank - 4) * 40.65 + 3 * 59.15
    SetLocalPositionXY(self.transform,182.38,-posY)

end

