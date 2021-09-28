-- FileName: FightAtkAction.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗主场景

module("FightAtkAction", package.seeall)

--[[
	@des:播放近身攻击特效
	@parm:pActionId 块数据
	@parm:pCallback	回调函数
--]]
function playNearBodyEffect( pBlockInfo, pCallback )
	print("playNearBodyEffect function")
	
	local attackHid = pBlockInfo.attacker
	local defendHid = pBlockInfo.defender
	local skillId = pBlockInfo.action
	--攻击前buffer
	FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.BEFORE, function()
		--播放怒气效果
		FightCardAction.playerRegeEffect(pBlockInfo, function ()
			--移动至目标位置
			FightCardAction.moveAction(attackHid, defendHid, function()
				--播放攻击动作
				FightCardAction.playAtkAction(pBlockInfo, function()
					--播放攻击特效
					FightCardAction.playAtkEffect(pBlockInfo, function()
						--播放被攻击者特效
						FightDefAction.playReaction(pBlockInfo, function()
							--攻击中buffer
							FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.IN, function()
								--返回至原始位置
								FightCardAction.moveBack(attackHid, function()
									--攻击后buffer
									FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.LATER, function()
										--死亡检查
										FightCardAction.playDieEffect(pBlockInfo, function ( ... )
											-- 执行完毕
											pCallback()
										end)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end

--[[
	@des:播放弹道特效
	@parm:pActionId 块数据
	@parm:pCallback	回调函数
--]]
function playBulletEffect( pBlockInfo, pCallback )
	print("playBulletEffect function")
	--攻击前buffer
	FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.BEFORE, function()
		--播放怒气特效
		FightCardAction.playerRegeEffect(pBlockInfo, function()
			--播放攻击动作
			FightCardAction.playAtkAction(pBlockInfo,function()
				--播放攻击特效
				FightCardAction.playAtkEffect(pBlockInfo,function()
					--播放弹道特效
					FightCardAction.runMultiBulletAction(pBlockInfo,function()
						--播放被攻击者特效
						FightDefAction.playReaction(pBlockInfo, function()
							--攻击中buffer
							FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.IN, function()
								--攻击后buffer
								FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.LATER, function()
									--死亡检查
									FightCardAction.playDieEffect(pBlockInfo, function ( ... )
										-- 执行完毕
										pCallback()
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end

--[[
    @des:固定地点释放
	@parm:pActionId 块数据
	@parm:pCallback	回调函数
--]]
function playPosAttackEffect( pBlockInfo, pCallback )
	print("playPosAttackEffect function")
    local attackHid = pBlockInfo.attacker
	local defendHid = pBlockInfo.defender
	local skillId = pBlockInfo.action

	local atkCard = FightScene.getCardByHid(attackHid)
	local defCard = FightScene.getCardByHid(defendHid)

	--计算目标地点
	local targetPos = ccp(g_winSize.width/2, g_winSize.height/2)
	if atkCard:isEnemy() == true then
		targetPos = EnemyCardNode.getAtkPos()
	else
		targetPos = PlayerCardNode.getAtkPos()
	end
	--攻击前buffer
	FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.BEFORE, function()
		--播放怒气特效
		FightCardAction.playerRegeEffect(pBlockInfo, function()
			--移动至固定点
			FightCardAction.moveTaretAction(attackHid, defendHid,targetPos, function ()
				--播放攻击动作
				FightCardAction.playAtkAction(pBlockInfo,function()
					--播放攻击特效
					FightCardAction.playAtkEffect(pBlockInfo,function()
						--播放被攻击者特效
						FightDefAction.playReaction(pBlockInfo, function()
							--攻击中buffer
							FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.IN, function()
								--返回至原始位置
								FightCardAction.moveBack(attackHid,function ()
									--攻击后buffer
									FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.LATER, function()
										--死亡检查
										FightCardAction.playDieEffect(pBlockInfo, function ( ... )
											-- 执行完毕
											pCallback()
										end)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end

--[[
    @des:原地释放
	@parm:pActionId 块数据
	@parm:pCallback	回调函数
--]]
function playOriginAttackEffect( pBlockInfo, pCallback )
	print("playOriginAttackEffect function")
	--攻击前buffer
	FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.BEFORE, function()
		--播放怒气特效
		FightCardAction.playerRegeEffect(pBlockInfo, function()
		    --播放攻击动作
			FightCardAction.playAtkAction(pBlockInfo,function()
				--播放攻击特效
				FightCardAction.playAtkEffect(pBlockInfo,function()
					--播放被攻击者特效
					FightDefAction.playReaction(pBlockInfo, function()
						--攻击中buffer
						FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.IN, function()
							--攻击后buffer
							FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.LATER, function()
								--死亡检查
								FightCardAction.playDieEffect(pBlockInfo, function ( ... )
									-- 执行完毕
									pCallback()
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end

--[[
	@des:固定点同行贯穿
	@parm:pBlockInfo 块数据
	@parm:pCallback 播放完毕回调
--]]
function playSameRowBulletEffect( pBlockInfo, pCallback )

	printTable("playSameRowBulletEffect",pBlockInfo)
	local attackHid = pBlockInfo.attacker
	local defendHid = pBlockInfo.defender

	local atkCard = FightScene.getCardByHid(attackHid)
	local defCard = FightScene.getCardByHid(defendHid)

	--找到最后面的卡牌
	local tarHid = defendHid
	for k,v in pairs(pBlockInfo.arrReaction) do
		local card = FightScene.getCardByHid(v.defender)
		if atkCard:isEnemy() then
			if card:getPositionY() < defCard:getPositionY() then
				tarHid = v.defender
				defCard = card
			end
		else
			if card:getPositionY() > defCard:getPositionY() then
				tarHid = v.defender
				defCard = card
			end
		end
	end
	--攻击前buffer
	FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.BEFORE, function()
		--播放怒气特效
		FightCardAction.playerRegeEffect(pBlockInfo, function()
			--移动至目标位置
			FightCardAction.moveRowAction(pBlockInfo, function ()
				--播放攻击动作
				FightCardAction.playAtkAction(pBlockInfo,function()
					--播放攻击特效
					FightCardAction.playAtkEffect(pBlockInfo,function()
						--播放弹道特效
						FightCardAction.runSingleBulletAction(pBlockInfo, tarHid,function()
							--播放被攻击者特效
							FightDefAction.playReaction(pBlockInfo, function()
								--攻击中buffer
								FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.IN, function()
									--返回原始位置
									FightCardAction.moveBack(attackHid, function ()
										--攻击后buffer
										FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.LATER, function()
											--死亡检查
											FightCardAction.playDieEffect(pBlockInfo, function ( ... )
												-- 执行完毕
												pCallback()
											end)
										end)
									end)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end

--[[
    @des:没有技能只有buffer
	@parm:pBlockInfo 块数据
	@parm:pCallback	回调函数
--]]
function playBufferEffect( pBlockInfo, pCallback )
	--攻击前buffer
	FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.BEFORE, function()
		--攻击中buffer
		FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.IN, function()
			--攻击后buffer
			FightBufferAction.playBufferEffect(pBlockInfo, BufferTimeType.LATER, function()
				--死亡检查
				FightCardAction.playDieEffect(pBlockInfo, function ( ... )
					--执行完毕
					pCallback()
				end)
			end)
		end)	
	end)
end

