
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_chess_task_puzzle = i3k_class("wnd_chess_task_puzzle",ui.wnd_base)

function wnd_chess_task_puzzle:ctor()
	self.callBack = nil
	self.imgs = {}
	self.puzzleId = 0
	self.nums = {1,2,3,4,5,6,7,8,9}
	self.preImg = nil
	self.picCfg = nil
	self.startState = 0
end

function wnd_chess_task_puzzle:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.desc:setText(i3k_get_string(17060))
	widgets.okBtn:onClick(self, self.startGame)

	for i = 1 , 9 do
		self.imgs[i] = widgets["img"..i]
	end
end

function wnd_chess_task_puzzle:refresh(id, func)
	self.callBack = func
	self.puzzleId = id
	self.picCfg = i3k_db_puzzle[id].imgs
	local imgCfg = self.picCfg
	self._layout.vars.titleText:setText(i3k_db_puzzle[id].name)
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	for i = 1 , 9 do
		self.imgs[i]:setImage(g_i3k_db.i3k_db_get_icon_path(imgCfg[i]))
		self.imgs[i]:onClick(self, self.movePic)
		self.imgs[i].seqNum = i
		if i+1 < 9 then
			local j = math.random(i+1,9)
			--i3k_log(j)
			self.nums[i], self.nums[j] = self.nums[j], self.nums[i]
		end
	end
end

function wnd_chess_task_puzzle:movePic(sender)
	if self.startState == 0 then
		return
	end
	self.imgs[sender.seqNum]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_puzzle[self.puzzleId].pressImage[self.nums[sender.seqNum]]))
	if self.preImg == sender then
		self.imgs[sender.seqNum]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_puzzle[self.puzzleId].imgs[self.nums[sender.seqNum]]))
		self.preImg = nil
		return
	end

	if self.preImg and self.preImg ~= sender then
		local i = self.preImg.seqNum
		local j = sender.seqNum
		local dec  = math.abs(i - j)
		if (dec ~= 1 and dec ~= 3) or (i%3 == 0 and j%3 == 1) or (i%3 == 1 and j%3 == 0) then
			self.imgs[sender.seqNum]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_puzzle[self.puzzleId].imgs[self.nums[sender.seqNum]]))
		else
			self.nums[i], self.nums[j] = self.nums[j], self.nums[i]
			local imgCfg = self.picCfg
			self.imgs[i]:setImage(g_i3k_db.i3k_db_get_icon_path(imgCfg[self.nums[i]]))
			self.imgs[j]:setImage(g_i3k_db.i3k_db_get_icon_path(imgCfg[self.nums[j]]))
			self.preImg = nil
			local trueNumber = 0
			for i = 1 , 9 do
				if i ~= self.nums[i] then
					break
				end
				trueNumber = i
			end
			if trueNumber == 9 then
				g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForSeconds(1)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChessTaskPuzzle,"quit")
				end)
			end
		end
		return
	end

	self.preImg = sender
end

function wnd_chess_task_puzzle:quit()
	if self.callBack then
		self.callBack()
	end
	local callback = function()
		g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskPuzzle)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskDiffAnimate)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskDiffAnimate, 1, callback)
	--self:onCloseUI()
end

function wnd_chess_task_puzzle:startGame(sender)
	self.startState = 1
	sender:hide()
	self._layout.vars.tips:hide()
	local imgCfg = self.picCfg
	for i,v in ipairs(self.nums) do
		self.imgs[i]:setImage(g_i3k_db.i3k_db_get_icon_path(imgCfg[v]))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_chess_task_puzzle.new()
	wnd:create(layout, ...)
	return wnd;
end

