PreDownload = PreDownload or BaseClass(BaseView)

function PreDownload:__init()
	self.wait_queue = {}
	self.next_check_download_time = 0
	self.update_retry_times = 0
	self.is_downloading = false
	self.delay_calc_download_list_timer = nil
	self.download_list = {}
	self:CalcDownloadList()

	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))
end

function PreDownload:__delete()
	Runner.Instance:RemoveRunObj(self)
	GlobalEventSystem:UnBind(self.task_change)

	if nil ~= self.delay_calc_download_list_timer then
		GlobalTimerQuest:CancelQuest(self.delay_calc_download_list_timer)
		self.delay_calc_download_list_timer = nil
	end
end

function PreDownload:OnTaskChange(task_event_type, task_id)
	if task_event_type == "accepted_add" then
		self:CalcNewDownloadItem()
	end
end

function PreDownload:Update(now_time, elapse_time)
	if now_time >= self.next_check_download_time then
		self:CalcNewDownloadItem()
		self.next_check_download_time = now_time + 5
	end

	self:CheckQueueDownload()
end

function PreDownload:Start()
	Runner.Instance:AddRunObj(self, 8)
end

function PreDownload:Stop()
	Runner.Instance:RemoveRunObj(self)
end

function PreDownload:CalcNewDownloadItem()
	if #self.download_list <= 0 then
		return
	end

	for i = #self.download_list, 1, -1 do
		local t = self.download_list[i]

		local is_in_scene = true
		if t.in_scene_id > 0 and Scene.Instance:GetSceneId() ~= t.in_scene_id then
			is_in_scene = false
		end

		local is_accept_task = true
		if t.accept_task > 0 and not TaskData.Instance:GetTaskIsAccepted(t.accept_task) then
			is_accept_task = false
		end

		local is_over_level = true
		if t.over_level > 0 and GameVoManager.Instance:GetMainRoleVo().level < t.over_level then
			is_over_level = false
		end

		local enough_quality = true
		if QualityConfig.QualityLevel > t.quality then  -- lQualityLevel高品质为0开始
			enough_quality = false
		end

		if is_in_scene
			and is_accept_task
			and enough_quality
			and is_over_level then

			table.insert(self.wait_queue, t)
			table.remove(self.download_list, i)
		end
	end
end

function PreDownload:CheckQueueDownload()
	if #self.wait_queue <= 0 or self.is_downloading then
		return
	end

	self.update_retry_times = 0
	self.is_downloading = true

	local t = table.remove(self.wait_queue, 1)
	self:DownloadBundle(t.bundle)
end

function PreDownload:DownloadBundle(bundle)
	print("PreDownload:DownloadBundle", bundle)

	AssetManager.UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)

		end,

		function(error_msg)
			if error_msg ~= nil and error_msg ~= "" then
				self:OnDownloadBundleFail(bundle)
			else
				print_log("download succ", bundle)
				self.is_downloading = false

				if self.update_retry_times > 0 then
					self.update_retry_times = 0
					AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
				end
			end
		end)
end

-- 下载bundle失败后再尝试
function PreDownload:OnDownloadBundleFail(bundle)
	if self.update_retry_times < 8 then
		self.update_retry_times = self.update_retry_times + 1
		if GLOBAL_CONFIG.param_list.update_url2 ~= nil then -- 切换下载地址
			if self.update_retry_times % 2 == 1
				and nil ~= GLOBAL_CONFIG.param_list.update_url2
				and "" ~= GLOBAL_CONFIG.param_list.update_url2 then
				AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url2
			else
				AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
			end
		end

		print_log("retry download ", bundle, ", retry times=", self.update_retry_times, ", url=", AssetManager.DownloadingURL)
		self:DownloadBundle(bundle)
	else
		self.is_downloading = false
	end
end

-- 0.高配 1.中配 2.低配 3.超低配
function PreDownload:CalcDownloadList()
	local list = {}

	-- 需要加载的bundle(策划配置)
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_02_yueyajian_main", in_scene_id = 101, accept_task = 0, over_level = 0}) -- 月牙涧地图
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_02_yueyajian_detail", in_scene_id = 101, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_03(z)_huaxuguo_main", in_scene_id = 101, accept_task = 0, over_level = 0}) -- 主城地图
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_03(z)_huaxuguo_detail", in_scene_id = 101, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_04_xuejianya_main", in_scene_id = 102, accept_task = 0, over_level = 0}) -- 雪剑崖地图
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_04_xuejianya_detail", in_scene_id = 102, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_zhufa_main", in_scene_id = 102, accept_task = 0, over_level = 0}) -- 竹筏副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_zhufa_detail", in_scene_id = 102, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_huajuan_main", in_scene_id = 102, accept_task = 0, over_level = 0}) -- 画卷副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_huajuan_detail", in_scene_id = 102, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_qin_main", in_scene_id = 102, accept_task = 0, over_level = 0}) -- 琴副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_qin_detail", in_scene_id = 102, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_gn_gonghuizhudi_main", in_scene_id = 103, accept_task = 0, over_level = 0}) -- boss引导副本-公会驻地--日常任务副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_gn_gonghuizhudi_detail", in_scene_id = 103, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_hd_wanglingtanxian_main", in_scene_id = 103, accept_task = 0, over_level = 0}) -- 王陵探险副本--日常任务副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_hd_wanglingtanxian_detail", in_scene_id = 103, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_1v1_main", in_scene_id = 104, accept_task = 0, over_level = 0}) -- 1v1地图--日常任务副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_1v1_detail", in_scene_id = 104, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_xiuluota_main", in_scene_id = 104, accept_task = 0, over_level = 0}) -- 修罗塔地图--日常任务副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_xiuluota_detail", in_scene_id = 104, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_yuansuzhanchang_main", in_scene_id = 104, accept_task = 0, over_level = 0}) -- 元素战场副本--日常任务副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_yuansuzhanchang_detail", in_scene_id = 104, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_05_yunzhidian_main", in_scene_id = 104, accept_task = 0, over_level = 0}) -- 云之巅地图
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_05_yunzhidian_detail", in_scene_id = 104, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_lingtuzhan_main", in_scene_id = 104, accept_task = 0, over_level = 0}) -- 领土战地图--竞技场场景
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_lingtuzhan_detail", in_scene_id = 104, accept_task = 0, over_level = 0})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_bagua_main", in_scene_id = 0, accept_task = 0, over_level = 130}) -- 八卦副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_bagua_detail", in_scene_id = 0, accept_task = 0, over_level = 130})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_weiqi_main", in_scene_id = 0, accept_task = 0, over_level = 130}) -- 围棋副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_fb_weiqi_detail", in_scene_id = 0, accept_task = 0, over_level = 130})	
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_08_mojiaozhudi_main", in_scene_id = 0, accept_task = 0, over_level = 130}) -- 魔教驻地地图-护送地图
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_08_mojiaozhudi_detail", in_scene_id = 0, accept_task = 0, over_level = 130})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_07_nvwajindi_main", in_scene_id = 0, accept_task = 0, over_level = 130}) -- 女娲禁地地图
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_07_nvwajindi_detail", in_scene_id = 0, accept_task = 0, over_level = 130})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_hd_wenquan_main", in_scene_id = 0, accept_task = 0, over_level = 150}) -- 温泉
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_hd_wenquan_detail", in_scene_id = 0, accept_task = 0, over_level = 150})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_gonghuizhengba_main", in_scene_id = 0, accept_task = 0, over_level = 150}) -- 公会争霸副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_gonghuizhengba_detail", in_scene_id = 0, accept_task = 0, over_level = 150})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_hd_shuijinghuanjing_main", in_scene_id = 0, accept_task = 0, over_level = 160}) -- 水晶幻境副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_hd_shuijinghuanjing_detail", in_scene_id = 0, accept_task = 0, over_level = 160})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_gongchengzhan_main", in_scene_id = 0, accept_task = 0, over_level = 160}) -- 攻城战副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_gongchengzhan_detail", in_scene_id = 0, accept_task = 0, over_level = 160})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_liujiezhanchang_main", in_scene_id = 0, accept_task = 0, over_level = 160}) -- 六界地图（主）
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_zc_liujiezhanchang_detail", in_scene_id = 0, accept_task = 0, over_level = 160})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_gn_hunyan_main", in_scene_id = 0, accept_task = 0, over_level = 170}) -- 结婚副本
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_gn_hunyan_detail", in_scene_id = 0, accept_task = 0, over_level = 170})
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_06_cangzhinan_main", in_scene_id = 0, accept_task = 0, over_level = 190}) -- 苍之南地图
	table.insert(list, {quality = 3, bundle = "scenes/map/w2_yw_06_cangzhinan_detail", in_scene_id = 0, accept_task = 0, over_level = 190})


	
	-- 处理成相关联的文件
	self.download_list = {}
	local dic = {}

	-- GetBundlesWithoutCached方法费性能，引起进度条卡顿较久
	local index = 1
	self.delay_calc_download_list_timer = GlobalTimerQuest:AddRunQuest(function ()
		if index > #list then
			GlobalTimerQuest:CancelQuest(self.delay_calc_download_list_timer)
			self.delay_calc_download_list_timer = nil
			return
		end

		local v = list[index]
		local uncached_bundles = AssetManager.GetBundlesWithoutCached(v.bundle)
		index = index + 1

		if uncached_bundles ~= nil and uncached_bundles.Length > 0 then
			local update_bundles = uncached_bundles:ToTable()
			for _, v2 in ipairs(update_bundles) do
				if not dic[v2] then
					dic[v2] = true
					table.insert(self.download_list, {quality = v.quality, bundle = v2, in_scene_id = v.in_scene_id, accept_task = v.accept_task, over_level = v.over_level})
				end
			end
		end
	end, 0.06)
end