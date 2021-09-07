DownloadHelper = {}

function DownloadHelper.DownloadBundle(bundle, retry_times, callback)
	DownloadHelper.DownloadBundleHelper(bundle, retry_times, 0, callback)
end

function DownloadHelper.DownloadBundleHelper(bundle, retry_times, cur_times, callback)
	AssetManager.UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)
		end,
		function(error_msg)
			if error_msg ~= nil and error_msg ~= "" then
				print_error("下载: ", bundle, " 失败: ", error_msg)

				if cur_times < retry_times then
					DownloadHelper.DownloadBundleHelper(bundle, retry_times, cur_times + 1, callback)
				else
					if callback then
						callback(false)
					end
				end
			else
				if callback then
					callback(true)
				end
			end
		end)
end
