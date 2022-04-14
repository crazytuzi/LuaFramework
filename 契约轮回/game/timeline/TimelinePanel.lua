TimelinePanel = TimelinePanel or class("TimelinePanel",BasePanel)

function TimelinePanel:ctor(  )
    self.abName = "timeline"
	self.assetName = "TimelinePanel"
    self.layer = "Max"
    self.use_background = false
    self.change_scene_close = false
    self.close_call_back = nil
    self.schedule_id = nil
end

function TimelinePanel:dctor(  )
    self.close_call_back = nil
    self.schedule_id = nil
end

function TimelinePanel:LoadCallBack(  )
    self.nodes={
        "img_mask",
        "monster_name/img_monster_name_bg",
        "monster_name/img_monster_name",
        "btn_skip_loading",
    }
    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    SetOrderIndex(self.gameObject,true,10)

    SetSizeDelta(self.img_mask.transform, ScreenWidth + 20, ScreenHeight + 20)-- 扩大点
    SetAlignType(self.btn_skip_loading, bit.bor(AlignType.Right, AlignType.Top))
end

function TimelinePanel:CloseCallBack(  )
    self.close_call_back()
end

function TimelinePanel:SetCloseCallback(call_back)
    self.close_call_back = call_back
end

function TimelinePanel:SetScheduleId(schedule_id)
    self.schedule_id = schedule_id
end

function TimelinePanel:InitUI(  )
    self.img_mask = GetImage(self.img_mask)
    self.img_monster_name = GetImage(self.img_monster_name)
    self.img_monster_name_bg = GetImage(self.img_monster_name_bg)
end

function TimelinePanel:AddEvent(  )

    --跳过剧情
    local function call_back()
        local function ok_call_back()
            self:FadeClosePanel()
        end
        Dialog.ShowTwo("Tip", "Skip animation?", "Confirm", ok_call_back, nil, "Cancel", nil, nil)

    end
    AddClickEvent(self.btn_skip_loading.gameObject,call_back)
end

--显示怪物名字
function TimelinePanel:ShowMonsterName(id,show_fade_time,show_time,hide_fade_time)
    
    local img_name = "monster_name_"..id
    lua_resMgr:SetImageTexture(self, self.img_monster_name, "timeline_image", img_name)


    local function call_back(new_num)
        self.img_monster_name.fillAmount = new_num
        self.img_monster_name_bg.fillAmount = new_num
    end
    TimelineManager:GetInstance():SmoothNumber(0,1,show_fade_time,call_back)

    local function call_back_alpha(new_num)
        SetAlpha(self.img_monster_name,new_num)
        SetAlpha(self.img_monster_name_bg,new_num)
    end

    TimelineManager:GetInstance():SmoothNumber(0,1,show_fade_time,call_back_alpha)

    --显示一段时间后逐渐消失
    local function call_back()
        TimelineManager:GetInstance():SmoothNumber(1,0,hide_fade_time,call_back_alpha)
    end
    GlobalSchedule:StartOnce(call_back,show_fade_time + show_time)
end


--界面渐暗关闭效果
function TimelinePanel:FadeClosePanel()

    if not self.schedule_id then
       return
    end

    --先停掉时间轴配置处理
    GlobalSchedule:Stop(self.schedule_id)
    self.schedule_id = nil

    local fade_time = 0.5
    local hide_time = 0.5

    SetVisible(self.img_mask,true)

    --逐渐变暗
    local function call_back_alpha(new_num)
        SetAlpha(self.img_mask,new_num)
    end
    TimelineManager:GetInstance():SmoothNumber(0,1,fade_time,call_back_alpha)

     --变暗一段时间后关闭
    local function call_back()
        self:Close()
    end
    GlobalSchedule:StartOnce(call_back,fade_time + hide_time)
end