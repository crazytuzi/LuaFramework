LuaNewRoleGuide = {}

function LuaNewRoleGuide.PreGuide()
	LogInfo("luanewroleguide preguide")
  	local winMgr = CEGUI.WindowManager:getSingleton()
	if winMgr then	
		if winMgr:isWindowPresent("npcsceneaniback") then
			return 0
		end
	end

	if GetNewRoleGuideManager() then
		local guideID = GetNewRoleGuideManager():getPreGuideID()
		if guideID == 30049 then
			GetGameUIManager():AddUIEffect(CEGUI.System:getSingleton():getGUISheet(), MHSD_UTILS.get_effectpath(10389), false)	
			GetNewRoleGuideManager():SendGuideFinish(guideID)
			GetNewRoleGuideManager():RemoveFromWaitingList(guideID)
		end
		local record = knight.gsp.task.GetCArrowEffectTableInstance():getRecorder(guideID)
		local pClickWnd = GetNewRoleGuideManager():GetGuideClickWnd(guideID)
		if pClickWnd then
			if record.screen == 1 then
				if (not pClickWnd:isVisible()) and MainControl.getInstanceNotCreate() and MainControl.getInstanceNotCreate():IsInMainControl(pClickWnd) then
       	   			MainControl.getInstanceNotCreate():ShowAllBtns(guideID)
       	   			GetNewRoleGuideManager():RemoveFromWaitingList(guideID)
					return 0
				end	
			elseif	record.screen == 0 then
				if not pClickWnd:isVisible() then 
					if MainControl.getInstanceNotCreate() and MainControl.getInstanceNotCreate():IsInMainControl(pClickWnd) then
       	    			if MainControl.getInstanceNotCreate():IsBtnShown(pClickWnd)then
       	    				MainControl.getInstanceNotCreate():ShowAllBtns(guideID)
       	    				GetNewRoleGuideManager():RemoveFromWaitingList(guideID)
							return 0
       	    			else
       	        			GetNewRoleGuideManager():SendGuideFinish(guideID)
       	        			MainControl.getInstanceNotCreate():GuideBtn(guideID)
       	        			GetNewRoleGuideManager():RemoveFromWaitingList(guideID);
							return 0
						end
					end
				end
			end	
		--yaoqianshu and pkentrance unlock
		elseif 30037 == guideID or 30038 == guideID then
       	   	GetNewRoleGuideManager():SendGuideFinish(guideID)
       	  	GetNewRoleGuideManager():RemoveFromWaitingList(guideID);
   			ClearButtonDlg.getInstanceAndShow():setGuideID(guideID)
			return 0
		elseif 30033 == guideID then	
       	   	GetNewRoleGuideManager():SendGuideFinish(guideID)
       	  	GetNewRoleGuideManager():RemoveFromWaitingList(guideID);
			ActivityEntrance.getInstanceAndShow()
			return 0
		end
	end	
	return 1
end

return LuaNewRoleGuide
