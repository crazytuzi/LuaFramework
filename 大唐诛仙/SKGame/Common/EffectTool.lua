EffectTool = {}

--获取模型对应的特效路径
--@param modelId 模型Id
--@param isWarning 是否为预警特效
function EffectTool.GetUrlByModelId(modelId, isWarning)
	-- if isWarning == true then
	-- 	return ""
	-- end
	-- if modelId == "1001" then --龙卫
	-- 	return "character/longwei/"
	-- elseif modelId == "1002" then --冰剑
	-- 	return "character/bingjian/"
	-- elseif modelId == "1003" then	--女巫
	-- 	return "character/anwu/"
	-- else --怪物
	-- 	return "boss/"..modelId.."/"
	-- end
end


--特效加载接口
--@param modelId		 模型Id
--@param effectName	  特效名称(String)
--@param target		  目标对象
--@param lifeTime		生命周期(float)	  
--@param targetIsParent  目标对象是否为特效父级(bool)
--@param boneName		绑定骨骼名称(String)
--@param targetPos		 目标位置(Vector3)
--@param scale		   缩放系数(Vector3)
--@param isWarning	   是否为预警特效(bool)
function EffectTool.AddEffect(modelId, effectName, target, lifeTime, targetIsParent, boneName, targetPos, scale, isWarning)
	-- if not target then return end
	-- local tf = target.transform
	-- if ToLuaIsNull(tf) then logWarn(" EffectTool.AddEffect get nil!!") return end
	-- local url = ""--EffectTool.GetUrlByModelId(modelId, isWarning)
	-- local effect = EffectRenderObjManager.Instance():CreateRenderObj(effectName, url..effectName..".unity3d", true)
	-- if not effect then
	-- 	error("特效：【"..url..effectName..".unity3d".."】 加载失败...")
	-- 	return
	-- end
	-- local node = effect:GetNode()
	-- local nodeTf = node:GetTransForm()
	-- if not nodeTf then 
	-- 	print("特效：【"..url..effectName..".unity3d".."】 出错...")
	-- 	return 
	-- end
	-- nodeTf.gameObject:SetActive(false)
	-- local tempPosition = Vector3.zero
	-- local sizeT = Mathf.Abs(tf.localScale.x)
	-- tempPosition = tempPosition * sizeT
	-- if targetIsParent then
	-- 	nodeTf.parent = tf
	-- 	node:SetLocalPosition(Vector3.zero)
 --   		node:SetLocalRotate(Quaternion.Euler(0, 0, 0))
	-- else
 --  		node:SetWorldPosition(tf.position + tempPosition)
 --   		node:SetLocalRotate(Quaternion.Euler(0, tf.eulerAngles.y, 0))
	-- end
	-- if not targetIsParent and targetPos then
	-- 	node:SetWorldPosition(targetPos)
	-- end
	-- if targetIsParent and targetPos then
	-- 	node:SetLocalPosition(targetPos)
	-- end
	-- if scale then
	-- 	node:SetScale(scale)
	-- end
	-- effect:compareLife()
	-- effect:setLoop(1)
	-- if boneName then
 --   	   effect:bindBone(boneName, target.gameObject, Vector3.New(-0.75, 0, 0))
	-- end
	-- effect:setSize(sizeT)
	-- if lifeTime and lifeTime > 0 then
	-- 	effect:setLife(lifeTime / 1000)
	-- end
	-- nodeTf.gameObject:SetActive(true)
	-- return effect
	return nil
end

--移除特效
--@param effectRenderObj  特效实体对象  
--@param removeCatche	 是否移除缓存(bool)
function EffectTool.RemoveEffect(effectRenderObj, removeCatche)
	EffectRenderObjManager.Instance():RemoveRenderobj(effectRenderObj, removeCatche)
end
	
