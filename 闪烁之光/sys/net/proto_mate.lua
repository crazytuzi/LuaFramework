-- 客户端协议打包解析描述文件(此文件工具生成 切勿手动修改)
local Proto = Proto or {}

-- 发送打包协议
Proto.send = {
   [10101] = {
      {name='sex', type='uint8'},
      {name='name', type='string'},
      {name='career', type='int16'},
      {name='playform', type='string'}
   },
   [10102] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [10103] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [10200] = {
      {name='battle_id', type='uint32'},
      {name='id', type='uint32'},
      {name='code', type='uint16'}
   },
   [10215] = {
      {name='base_id', type='uint32'},
      {name='x', type='uint16'},
      {name='y', type='uint16'},
      {name='dir', type='uint8'}
   },
   [10300] = {
   },
   [10309] = {
      {name='signature', type='string'}
   },
   [10312] = {
   },
   [10315] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [10316] = {
      {name='type', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='idx', type='uint32'}
   },
   [10317] = {
   },
   [10318] = {
      {name='auto_pk', type='uint8'}
   },
   [10319] = {
   },
   [10320] = {
   },
   [10322] = {
      {name='code', type='uint8'}
   },
   [10325] = {
   },
   [10327] = {
      {name='face_id', type='uint32'}
   },
   [10328] = {
   },
   [10329] = {
      {name='backdrop_id', type='uint32'}
   },
   [10330] = {
   },
   [10332] = {
   },
   [10333] = {
   },
   [10343] = {
      {name='name', type='string'},
      {name='sex', type='uint8'}
   },
   [10345] = {
   },
   [10346] = {
      {name='id', type='uint32'}
   },
   [10347] = {
      {name='id', type='uint32'}
   },
   [10348] = {
      {name='is_show_vip', type='uint8'}
   },
   [10380] = {
   },
   [10391] = {
      {name='msg', type='string'}
   },
   [10392] = {
      {name='data', type='byte'},
      {name='data_len', type='uint32'}
   },
   [10394] = {
   },
   [10395] = {
      {name='age', type='int8'}
   },
   [10397] = {
      {name='status', type='uint8'}
   },
   [10399] = {
      {name='msg', type='string'}
   },
   [10400] = {
   },
   [10402] = {
      {name='id', type='uint32'}
   },
   [10405] = {
      {name='id', type='uint32'}
   },
   [10406] = {
      {name='id', type='uint32'}
   },
   [10500] = {
   },
   [10501] = {
   },
   [10502] = {
   },
   [10503] = {
   },
   [10515] = {
      {name='id', type='uint32'},
      {name='quantity', type='uint16'},
      {name='args', type='array', fields={
          {name='name', type='uint8'},
          {name='value', type='uint32'},
          {name='str', type='string'}
      }}
   },
   [10520] = {
      {name='id', type='uint32'},
      {name='storage', type='uint8'}
   },
   [10521] = {
      {name='storage', type='uint8'},
      {name='args', type='array', fields={
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [10522] = {
      {name='storage', type='uint8'},
      {name='args', type='array', fields={
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='num', type='uint16'}
      }}
   },
   [10523] = {
      {name='id', type='uint32'},
      {name='num', type='uint16'}
   },
   [10524] = {
      {name='star_list', type='array', fields={
          {name='star', type='uint8'}
      }}
   },
   [10525] = {
   },
   [10526] = {
      {name='type', type='uint8'}
   },
   [10528] = {
   },
   [10535] = {
      {name='type', type='uint8'},
      {name='id', type='uint32'},
      {name='partner_id', type='uint32'},
      {name='code', type='uint32'}
   },
   [10536] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [10800] = {
   },
   [10801] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [10802] = {
   },
   [10804] = {
      {name='ids', type='array', fields={
          {name='id', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [10805] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [10806] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [10810] = {
      {name='issue_type', type='uint8'},
      {name='title', type='string'},
      {name='content', type='string'},
      {name='phone', type='string'},
      {name='email', type='string'},
      {name='phone_info', type='string'},
      {name='id', type='uint32'}
   },
   [10811] = {
      {name='id', type='uint32'},
      {name='score', type='uint8'}
   },
   [10813] = {
   },
   [10814] = {
      {name='id', type='uint32'}
   },
   [10900] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='hour', type='uint32'},
      {name='interdict', type='string'}
   },
   [10901] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='hour', type='uint32'},
      {name='banned', type='string'}
   },
   [10902] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='stop_role', type='string'}
   },
   [10905] = {
   },
   [10906] = {
   },
   [10907] = {
   },
   [10922] = {
   },
   [10923] = {
      {name='id', type='uint16'}
   },
   [10924] = {
   },
   [10925] = {
      {name='id', type='uint16'}
   },
   [10926] = {
   },
   [10927] = {
      {name='time', type='uint32'}
   },
   [10928] = {
   },
   [10929] = {
   },
   [10930] = {
   },
   [10931] = {
   },
   [10945] = {
      {name='card_id', type='string'}
   },
   [10946] = {
   },
   [10947] = {
      {name='charge_id', type='uint32'},
      {name='notify_url', type='string'}
   },
   [10950] = {
   },
   [10952] = {
      {name='id', type='uint32'}
   },
   [10955] = {
   },
   [10956] = {
      {name='key', type='uint16'},
      {name='val', type='uint32'}
   },
   [10957] = {
   },
   [10958] = {
      {name='combat_msg', type='string'}
   },
   [10960] = {
   },
   [10961] = {
   },
   [10971] = {
      {name='bid', type='uint32'}
   },
   [10985] = {
   },
   [10986] = {
      {name='id', type='uint32'}
   },
   [10987] = {
   },
   [10988] = {
   },
   [10989] = {
   },
   [10990] = {
      {name='code', type='uint32'},
      {name='cmd', type='uint32'}
   },
   [10991] = {
   },
   [10992] = {
   },
   [10993] = {
      {name='flag', type='uint8'}
   },
   [10999] = {
      {name='msg', type='string'}
   },
   [1110] = {
      {name='args', type='array', fields={
          {name='key', type='string'},
          {name='val', type='string'}
      }}
   },
   [1190] = {
   },
   [1197] = {
      {name='sign', type='string'},
      {name='idx', type='uint32'},
      {name='code', type='uint16'},
      {name='time', type='uint32'}
   },
   [1198] = {
      {name='time', type='uint32'}
   },
   [1199] = {
   },
   [11000] = {
   },
   [11001] = {
   },
   [11002] = {
   },
   [11003] = {
      {name='partner_id', type='uint32'}
   },
   [11004] = {
      {name='partner_id', type='uint32'}
   },
   [11005] = {
      {name='partner_id', type='uint32'},
      {name='expend1', type='array', fields={
          {name='partner_id', type='uint32'}
      }},
      {name='expend2', type='array', fields={
          {name='partner_id', type='uint32'}
      }},
      {name='item_expend', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [11006] = {
   },
   [11007] = {
   },
   [11008] = {
      {name='bid', type='uint32'},
      {name='num', type='uint32'}
   },
   [11009] = {
   },
   [11010] = {
      {name='partner_id', type='uint32'},
      {name='item_id', type='uint32'}
   },
   [11011] = {
      {name='partner_id', type='uint32'},
      {name='pos_id', type='uint32'}
   },
   [11012] = {
   },
   [11015] = {
      {name='partner_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [11016] = {
      {name='partner_id', type='uint32'}
   },
   [11017] = {
   },
   [11019] = {
      {name='partner_id', type='uint32'},
      {name='skin_id', type='uint32'}
   },
   [11020] = {
   },
   [11025] = {
   },
   [11026] = {
      {name='partner_ids', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11030] = {
      {name='partner_id', type='uint32'},
      {name='pos_id', type='uint8'},
      {name='artifact_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [11031] = {
   },
   [11032] = {
      {name='partner_id', type='uint32'},
      {name='artifact_id', type='uint32'},
      {name='expends', type='array', fields={
          {name='artifact_id', type='uint32'}
      }}
   },
   [11033] = {
      {name='partner_id', type='uint32'},
      {name='artifact_id', type='uint32'},
      {name='skills', type='array', fields={
          {name='skill_id', type='uint32'}
      }},
      {name='luck_item', type='uint8'}
   },
   [11034] = {
      {name='partner_id', type='uint32'},
      {name='artifact_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [11035] = {
      {name='artifact_id', type='uint32'}
   },
   [11036] = {
      {name='item_id', type='uint32'},
      {name='expends', type='array', fields={
          {name='artifact_id', type='uint32'}
      }}
   },
   [11037] = {
   },
   [11038] = {
   },
   [11040] = {
   },
   [11041] = {
      {name='partner_id', type='uint32'},
      {name='start', type='uint8'},
      {name='num', type='uint8'}
   },
   [11042] = {
      {name='partner_id', type='uint32'}
   },
   [11043] = {
      {name='partner_id', type='uint32'},
      {name='msg', type='string'}
   },
   [11044] = {
      {name='partner_id', type='uint32'},
      {name='comment_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [11045] = {
      {name='partner_id', type='uint32'}
   },
   [11046] = {
   },
   [11047] = {
   },
   [11048] = {
   },
   [11050] = {
   },
   [11051] = {
      {name='fields', type='array', fields={
          {name='pos', type='uint32'},
          {name='partner_id', type='uint32'}
      }}
   },
   [11052] = {
   },
   [11053] = {
      {name='pos', type='uint8'}
   },
   [11055] = {
      {name='is_point', type='uint8'}
   },
   [11056] = {
   },
   [11060] = {
      {name='partner_id', type='uint32'},
      {name='channel', type='uint16'}
   },
   [11061] = {
      {name='r_rid', type='uint32'},
      {name='r_srvid', type='string'},
      {name='partner_id', type='uint32'}
   },
   [11062] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [11063] = {
      {name='partner_id', type='uint32'}
   },
   [11065] = {
      {name='partner_id', type='uint32'}
   },
   [11066] = {
      {name='partner_id', type='uint32'}
   },
   [11067] = {
      {name='partner_id', type='uint32'}
   },
   [11068] = {
      {name='partner_id', type='uint32'}
   },
   [11070] = {
      {name='partner_bid', type='uint32'}
   },
   [11071] = {
      {name='partner_id', type='uint32'}
   },
   [11072] = {
      {name='partner_id', type='uint32'}
   },
   [11073] = {
   },
   [11074] = {
      {name='list', type='array', fields={
          {name='skin_ids', type='uint32'}
      }}
   },
   [11075] = {
      {name='list', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11076] = {
      {name='list', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11077] = {
      {name='partner_bid', type='uint32'}
   },
   [11078] = {
      {name='id', type='uint32'},
      {name='flag', type='uint8'}
   },
   [11079] = {
      {name='base_id', type='uint32'},
      {name='num', type='uint32'}
   },
   [11080] = {
      {name='base_id', type='uint32'},
      {name='num', type='uint32'}
   },
   [11081] = {
      {name='base_id', type='uint32'},
      {name='num', type='uint32'}
   },
   [11082] = {
   },
   [11083] = {
      {name='partner_id', type='uint32'},
      {name='item_id', type='uint32'}
   },
   [11085] = {
   },
   [11086] = {
      {name='partner_id', type='uint32'}
   },
   [11087] = {
      {name='list', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11088] = {
      {name='item_ids', type='array', fields={
          {name='item_id', type='uint32'}
      }}
   },
   [11089] = {
      {name='item_ids', type='array', fields={
          {name='item_id', type='uint32'}
      }}
   },
   [11090] = {
      {name='partner_id', type='uint32'},
      {name='holy_eqm_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [11091] = {
   },
   [11092] = {
      {name='partner_ids', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11093] = {
      {name='partner_id', type='uint32'},
      {name='holy_eqm_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [11094] = {
      {name='partner_id', type='uint32'},
      {name='holy_eqm_id', type='uint32'},
      {name='pos', type='array', fields={
          {name='pos', type='uint8'}
      }}
   },
   [11095] = {
   },
   [11096] = {
      {name='partner_id', type='uint32'},
      {name='pos', type='uint8'},
      {name='skill_id', type='uint32'}
   },
   [11097] = {
      {name='partner_id', type='uint32'},
      {name='pos', type='uint8'}
   },
   [11098] = {
      {name='partner_id', type='uint32'},
      {name='pos', type='uint8'}
   },
   [11099] = {
      {name='partner_ids', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11100] = {
      {name='drama_bid', type='uint32'},
      {name='step_id', type='uint8'}
   },
   [11102] = {
      {name='drama_bid', type='uint32'}
   },
   [11111] = {
      {name='type', type='uint16'},
      {name='bid', type='uint32'}
   },
   [11121] = {
      {name='id', type='uint32'},
      {name='n', type='uint32'}
   },
   [11122] = {
      {name='id', type='uint32'},
      {name='is_skip', type='uint32'}
   },
   [11200] = {
   },
   [11201] = {
      {name='id', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint8'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [11211] = {
      {name='type', type='uint8'}
   },
   [11212] = {
      {name='type', type='uint8'},
      {name='formation_type', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [11213] = {
      {name='type_list', type='array', fields={
          {name='type', type='uint8'}
      }}
   },
   [11300] = {
   },
   [11301] = {
   },
   [11302] = {
      {name='set_id', type='uint32'},
      {name='pos_id', type='uint32'},
      {name='partner_id', type='uint32'}
   },
   [11303] = {
      {name='set_id', type='uint32'},
      {name='pos_id', type='uint32'},
      {name='partner_id', type='uint32'}
   },
   [11304] = {
      {name='set_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [11305] = {
      {name='set_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [11306] = {
      {name='id', type='uint32'},
      {name='set_id', type='uint32'}
   },
   [11307] = {
      {name='set_id', type='uint32'}
   },
   [11308] = {
   },
   [11310] = {
      {name='set_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [11311] = {
      {name='set_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [11320] = {
   },
   [11321] = {
   },
   [11322] = {
      {name='tower', type='uint32'}
   },
   [11323] = {
   },
   [11324] = {
      {name='tower', type='uint32'}
   },
   [11325] = {
      {name='tower', type='uint32'}
   },
   [11326] = {
   },
   [11327] = {
   },
   [11328] = {
      {name='id', type='uint32'}
   },
   [11329] = {
   },
   [11330] = {
   },
   [11331] = {
      {name='type', type='uint8'},
      {name='count', type='uint8'}
   },
   [11332] = {
   },
   [11333] = {
      {name='replay_id', type='uint32'},
      {name='channel', type='uint16'},
      {name='tower', type='uint32'}
   },
   [12700] = {
   },
   [12701] = {
      {name='base_id', type='uint32'}
   },
   [12702] = {
   },
   [12703] = {
      {name='base_id', type='uint32'}
   },
   [12704] = {
   },
   [12720] = {
      {name='to_rid', type='uint32'},
      {name='to_srv_id', type='string'},
      {name='len', type='uint8'},
      {name='msg', type='string'}
   },
   [12723] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [12725] = {
      {name='voice', type='byte'},
      {name='voice_len', type='uint16'},
      {name='time', type='uint8'},
      {name='type', type='uint8'}
   },
   [12726] = {
      {name='srv_id', type='string'},
      {name='voice_id', type='uint32'}
   },
   [12729] = {
   },
   [12730] = {
      {name='type', type='uint32'},
      {name='is_push', type='uint8'}
   },
   [12731] = {
   },
   [12732] = {
      {name='type', type='uint32'},
      {name='msg', type='string'}
   },
   [12762] = {
      {name='channel', type='uint16'},
      {name='len', type='uint8'},
      {name='msg', type='string'},
      {name='sign', type='string'}
   },
   [12764] = {
      {name='channel', type='uint16'},
      {name='id', type='string'},
      {name='msg', type='string'}
   },
   [12766] = {
      {name='channel', type='uint16'}
   },
   [12767] = {
   },
   [12768] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='channel', type='uint16'},
      {name='msg', type='string'}
   },
   [12770] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='type', type='uint8'},
      {name='msg', type='string'},
      {name='history', type='array', fields={
          {name='id', type='uint8'}
      }}
   },
   [12771] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [12772] = {
   },
   [12900] = {
      {name='type', type='uint16'},
      {name='start', type='uint8'},
      {name='num', type='uint8'},
      {name='is_cluster', type='uint8'}
   },
   [12901] = {
      {name='type', type='uint16'},
      {name='is_cluster', type='uint8'}
   },
   [12902] = {
      {name='is_cluster', type='uint8'}
   },
   [12903] = {
      {name='start', type='uint8'},
      {name='num', type='uint8'},
      {name='is_cluster', type='uint8'}
   },
   [12904] = {
      {name='start', type='uint8'},
      {name='num', type='uint8'}
   },
   [13000] = {
   },
   [13002] = {
   },
   [13003] = {
      {name='is_auto', type='uint8'}
   },
   [13004] = {
   },
   [13005] = {
      {name='dun_id', type='uint32'},
      {name='num', type='uint16'}
   },
   [13006] = {
   },
   [13008] = {
   },
   [13009] = {
      {name='id', type='uint32'}
   },
   [13011] = {
   },
   [13012] = {
   },
   [13013] = {
   },
   [13014] = {
      {name='chapter_id', type='uint32'},
      {name='award_id', type='uint32'}
   },
   [13015] = {
      {name='dun_id', type='uint32'}
   },
   [13017] = {
   },
   [13018] = {
   },
   [13019] = {
   },
   [13020] = {
   },
   [13030] = {
   },
   [13031] = {
      {name='id', type='uint32'}
   },
   [13032] = {
      {name='id', type='uint32'}
   },
   [13300] = {
   },
   [13303] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13305] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='agreed', type='uint8'}
   },
   [13306] = {
      {name='role_ids', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [13307] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13309] = {
      {name='role_ids', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [13311] = {
   },
   [13312] = {
   },
   [13314] = {
      {name='name', type='string'}
   },
   [13315] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13316] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='code', type='uint8'}
   },
   [13317] = {
      {name='code', type='uint8'},
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [13320] = {
   },
   [13330] = {
   },
   [13332] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13333] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13334] = {
      {name='role_ids', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [13401] = {
      {name='type', type='uint8'}
   },
   [13402] = {
      {name='eid', type='uint32'},
      {name='num', type='uint32'}
   },
   [13403] = {
      {name='type', type='uint32'}
   },
   [13405] = {
      {name='type', type='uint32'}
   },
   [13407] = {
      {name='order', type='uint32'},
      {name='type', type='uint32'},
      {name='buy_type', type='uint32'},
      {name='num', type='uint32'}
   },
   [13408] = {
      {name='type', type='uint8'}
   },
   [13409] = {
      {name='type', type='uint8'}
   },
   [13410] = {
      {name='type', type='uint8'},
      {name='pos', type='uint32'}
   },
   [13411] = {
      {name='type', type='uint8'}
   },
   [13412] = {
   },
   [13413] = {
      {name='id', type='uint32'}
   },
   [13414] = {
   },
   [13415] = {
      {name='type', type='uint32'}
   },
   [13416] = {
      {name='order', type='uint32'},
      {name='type', type='uint32'},
      {name='buy_type', type='uint32'}
   },
   [13417] = {
      {name='type', type='uint32'}
   },
   [13419] = {
      {name='num', type='uint32'}
   },
   [13420] = {
   },
   [13500] = {
      {name='name', type='string'},
      {name='sign', type='string'},
      {name='apply_type', type='uint8'},
      {name='apply_lev', type='uint8'},
      {name='apply_power', type='uint32'}
   },
   [13501] = {
      {name='page', type='uint16'},
      {name='flag', type='uint8'},
      {name='num', type='uint16'},
      {name='name', type='string'}
   },
   [13503] = {
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='type', type='uint8'}
   },
   [13505] = {
      {name='type', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13507] = {
      {name='page', type='uint8'},
      {name='num', type='uint8'}
   },
   [13513] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13514] = {
   },
   [13516] = {
   },
   [13518] = {
   },
   [13519] = {
   },
   [13520] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='position', type='uint8'}
   },
   [13521] = {
      {name='sign', type='string'}
   },
   [13522] = {
      {name='apply_type', type='uint8'},
      {name='apply_lev', type='uint8'},
      {name='apply_power', type='uint32'}
   },
   [13523] = {
   },
   [13524] = {
      {name='type', type='uint8'}
   },
   [13534] = {
   },
   [13535] = {
      {name='type', type='uint8'},
      {name='num', type='uint16'},
      {name='msg_id', type='uint8'},
      {name='loss_type', type='uint8'}
   },
   [13536] = {
      {name='id', type='uint32'}
   },
   [13540] = {
      {name='id', type='uint32'}
   },
   [13541] = {
   },
   [13545] = {
   },
   [13546] = {
   },
   [13558] = {
   },
   [13565] = {
   },
   [13568] = {
      {name='name', type='string'}
   },
   [13573] = {
   },
   [13574] = {
      {name='box_id', type='uint8'}
   },
   [13575] = {
   },
   [13576] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13577] = {
   },
   [13578] = {
   },
   [13579] = {
      {name='type', type='uint8'},
      {name='id_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [13580] = {
      {name='content', type='string'}
   },
   [13601] = {
   },
   [13602] = {
      {name='type', type='uint8'},
      {name='day_type', type='uint32'},
      {name='id', type='uint32'},
      {name='item', type='uint32'}
   },
   [13603] = {
   },
   [13604] = {
   },
   [13605] = {
   },
   [13606] = {
      {name='id', type='uint32'}
   },
   [13607] = {
   },
   [13608] = {
      {name='id', type='uint16'}
   },
   [13609] = {
   },
   [14100] = {
   },
   [14101] = {
   },
   [14102] = {
   },
   [14103] = {
      {name='id', type='uint8'}
   },
   [16400] = {
   },
   [16401] = {
   },
   [16402] = {
      {name='id', type='uint32'}
   },
   [16601] = {
   },
   [16602] = {
   },
   [16603] = {
      {name='bid', type='uint32'}
   },
   [16604] = {
      {name='bid', type='uint32'},
      {name='aim', type='uint32'},
      {name='arg', type='uint32'}
   },
   [16605] = {
      {name='bid_list', type='array', fields={
          {name='bid', type='uint32'}
      }}
   },
   [16607] = {
   },
   [16620] = {
      {name='id_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [16630] = {
   },
   [16631] = {
   },
   [16633] = {
   },
   [16634] = {
   },
   [16635] = {
   },
   [16636] = {
      {name='number', type='string'},
      {name='code', type='string'}
   },
   [16637] = {
   },
   [16638] = {
      {name='type', type='uint32'},
      {name='type2', type='uint32'}
   },
   [16639] = {
   },
   [16640] = {
      {name='type', type='uint32'},
      {name='id', type='uint32'}
   },
   [16641] = {
   },
   [16642] = {
      {name='type', type='uint32'}
   },
   [16643] = {
      {name='type', type='uint32'},
      {name='type2', type='uint32'}
   },
   [16650] = {
      {name='bid', type='uint32'}
   },
   [16651] = {
   },
   [16652] = {
      {name='id', type='uint32'}
   },
   [16653] = {
   },
   [16654] = {
      {name='id', type='uint32'}
   },
   [16660] = {
   },
   [16661] = {
      {name='bid', type='uint32'},
      {name='aim', type='uint32'},
      {name='num', type='uint32'}
   },
   [16665] = {
      {name='bid', type='uint32'},
      {name='ids', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16666] = {
      {name='bid', type='uint32'}
   },
   [16670] = {
   },
   [16671] = {
      {name='count', type='uint8'},
      {name='flag', type='uint8'}
   },
   [16672] = {
   },
   [16673] = {
      {name='id', type='uint8'}
   },
   [16674] = {
      {name='type', type='uint8'}
   },
   [16675] = {
      {name='num', type='uint32'}
   },
   [16676] = {
   },
   [16680] = {
   },
   [16681] = {
   },
   [16682] = {
      {name='pos', type='uint8'}
   },
   [16683] = {
   },
   [16684] = {
      {name='num', type='uint16'}
   },
   [16685] = {
      {name='type', type='uint8'}
   },
   [16686] = {
      {name='partner_id', type='uint32'},
      {name='partner_bid', type='uint32'},
      {name='expend', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [16687] = {
      {name='bid', type='uint32'}
   },
   [16688] = {
   },
   [16689] = {
      {name='id', type='uint32'},
      {name='num', type='uint32'}
   },
   [16690] = {
   },
   [16691] = {
      {name='type', type='uint32'}
   },
   [16692] = {
      {name='num', type='uint32'}
   },
   [16693] = {
      {name='type', type='uint32'}
   },
   [16694] = {
      {name='type', type='uint32'}
   },
   [16695] = {
      {name='card_id', type='string'}
   },
   [16696] = {
   },
   [16697] = {
   },
   [16698] = {
      {name='id', type='uint32'}
   },
   [16700] = {
   },
   [16705] = {
   },
   [16706] = {
      {name='card_type', type='uint8'}
   },
   [16707] = {
   },
   [16708] = {
   },
   [16710] = {
   },
   [16711] = {
      {name='lev', type='uint8'}
   },
   [16712] = {
   },
   [16713] = {
      {name='id', type='uint8'}
   },
   [16800] = {
      {name='idx', type='uint32'},
      {name='val', type='uint32'},
      {name='str', type='string'}
   },
   [16801] = {
   },
   [16802] = {
   },
   [16900] = {
   },
   [16901] = {
   },
   [16903] = {
      {name='id', type='uint32'}
   },
   [16904] = {
   },
   [19800] = {
   },
   [19801] = {
      {name='code', type='uint32'}
   },
   [19802] = {
   },
   [19804] = {
   },
   [19805] = {
      {name='id', type='uint8'}
   },
   [19806] = {
   },
   [19807] = {
   },
   [19810] = {
      {name='code', type='uint32'}
   },
   [19811] = {
   },
   [19812] = {
      {name='id', type='uint8'}
   },
   [19901] = {
      {name='type', type='uint8'}
   },
   [19902] = {
      {name='type', type='uint8'},
      {name='cond_type', type='uint32'},
      {name='start', type='uint32'},
      {name='num', type='uint8'}
   },
   [19903] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'},
      {name='combat_type', type='uint8'}
   },
   [19904] = {
      {name='id', type='uint32'},
      {name='type', type='uint8'},
      {name='srv_id', type='string'},
      {name='combat_type', type='uint8'}
   },
   [19905] = {
      {name='id', type='uint32'},
      {name='channel', type='uint16'},
      {name='srv_id', type='string'},
      {name='combat_type', type='uint8'}
   },
   [19906] = {
   },
   [19907] = {
      {name='replay_id', type='uint32'},
      {name='partner_id', type='uint32'},
      {name='type', type='uint8'},
      {name='srv_id', type='string'},
      {name='combat_type', type='uint8'}
   },
   [19908] = {
      {name='hall_srv_id', type='string'},
      {name='replay_id', type='uint32'},
      {name='srv_id', type='string'},
      {name='type', type='uint8'},
      {name='channel', type='uint16'}
   },
   [20000] = {
   },
   [20001] = {
   },
   [20002] = {
   },
   [20004] = {
   },
   [20005] = {
   },
   [20006] = {
   },
   [20008] = {
   },
   [20009] = {
   },
   [20013] = {
   },
   [20014] = {
      {name='target_id', type='uint32'},
      {name='target_srv_id', type='string'},
      {name='is_province', type='uint8'}
   },
   [20015] = {
      {name='target_id', type='uint32'},
      {name='target_srv_id', type='string'},
      {name='is_agree', type='uint8'}
   },
   [20016] = {
      {name='target_id', type='uint32'},
      {name='target_srv_id', type='string'},
      {name='is_agree', type='uint8'}
   },
   [20019] = {
   },
   [20020] = {
   },
   [20022] = {
      {name='speed', type='uint8'}
   },
   [20026] = {
   },
   [20027] = {
   },
   [20028] = {
   },
   [20029] = {
      {name='replay_id', type='uint32'}
   },
   [20030] = {
   },
   [20033] = {
   },
   [20034] = {
      {name='replay_id', type='uint32'},
      {name='channel', type='uint16'},
      {name='target_name', type='string'},
      {name='share_type', type='uint8'}
   },
   [20036] = {
      {name='replay_id', type='uint32'},
      {name='replay_srv_id', type='string'}
   },
   [20060] = {
      {name='combat_type', type='uint16'}
   },
   [20062] = {
   },
   [20063] = {
   },
   [20200] = {
   },
   [20201] = {
   },
   [20202] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [20203] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='is_auto', type='uint8'}
   },
   [20204] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='pos', type='uint8'}
   },
   [20206] = {
   },
   [20207] = {
      {name='num', type='uint16'}
   },
   [20208] = {
   },
   [20209] = {
      {name='num', type='uint8'}
   },
   [20220] = {
   },
   [20221] = {
   },
   [20222] = {
   },
   [20223] = {
   },
   [20250] = {
   },
   [20251] = {
   },
   [20252] = {
   },
   [20253] = {
   },
   [20254] = {
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'}
   },
   [20255] = {
   },
   [20256] = {
   },
   [20258] = {
   },
   [20260] = {
   },
   [20261] = {
   },
   [20262] = {
   },
   [20263] = {
      {name='group', type='uint8'},
      {name='pos', type='uint8'}
   },
   [20280] = {
   },
   [20281] = {
   },
   [20300] = {
   },
   [20301] = {
      {name='activity', type='uint16'}
   },
   [20500] = {
   },
   [20501] = {
      {name='boss_id', type='uint32'}
   },
   [20502] = {
      {name='boss_id', type='uint32'}
   },
   [20530] = {
   },
   [20531] = {
   },
   [20532] = {
      {name='boss_id', type='uint32'}
   },
   [20533] = {
      {name='boss_id', type='uint32'}
   },
   [20535] = {
   },
   [20537] = {
      {name='boss_id', type='uint32'}
   },
   [20538] = {
      {name='boss_id', type='uint32'}
   },
   [20540] = {
   },
   [20541] = {
      {name='boss_list', type='array', fields={
          {name='boss_id', type='uint32'}
      }}
   },
   [20542] = {
   },
   [20600] = {
   },
   [20601] = {
   },
   [20602] = {
   },
   [20604] = {
   },
   [20605] = {
      {name='plist', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [20606] = {
   },
   [20607] = {
      {name='skill_id', type='uint32'},
      {name='val', type='uint32'}
   },
   [20608] = {
      {name='room_id', type='uint8'}
   },
   [20609] = {
   },
   [20610] = {
      {name='id', type='uint32'}
   },
   [20611] = {
   },
   [20620] = {
      {name='room_id', type='uint8'},
      {name='action', type='uint8'},
      {name='ext_list', type='array', fields={
          {name='type', type='uint8'},
          {name='val', type='uint32'}
      }}
   },
   [20632] = {
   },
   [20633] = {
      {name='id', type='uint32'}
   },
   [20634] = {
   },
   [20635] = {
      {name='id', type='uint32'}
   },
   [20636] = {
      {name='num', type='uint8'}
   },
   [20640] = {
      {name='floor', type='uint8'},
      {name='is_notice', type='uint8'}
   },
   [20641] = {
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'}
   },
   [20642] = {
   },
   [20643] = {
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'},
      {name='is_skip', type='uint8'}
   },
   [20644] = {
   },
   [20646] = {
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'},
      {name='id', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [20647] = {
   },
   [20648] = {
      {name='num', type='uint8'}
   },
   [20651] = {
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'}
   },
   [20652] = {
   },
   [20653] = {
   },
   [20654] = {
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'},
      {name='type', type='uint8'}
   },
   [20655] = {
   },
   [20656] = {
      {name='rid', type='uint32'},
      {name='srvid', type='string'}
   },
   [20657] = {
   },
   [20658] = {
   },
   [20659] = {
   },
   [20660] = {
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'}
   },
   [20700] = {
   },
   [20701] = {
   },
   [20702] = {
      {name='pos', type='uint8'},
      {name='num', type='uint8'}
   },
   [20703] = {
      {name='pos', type='uint8'}
   },
   [20706] = {
   },
   [21000] = {
   },
   [21001] = {
      {name='id', type='uint8'}
   },
   [21002] = {
   },
   [21003] = {
   },
   [21004] = {
   },
   [21005] = {
   },
   [21006] = {
   },
   [21007] = {
      {name='type', type='uint8'}
   },
   [21008] = {
   },
   [21009] = {
   },
   [21010] = {
   },
   [21011] = {
   },
   [21012] = {
   },
   [21013] = {
      {name='id', type='uint8'}
   },
   [21014] = {
      {name='id', type='uint8'}
   },
   [21015] = {
   },
   [21016] = {
      {name='charge_id', type='uint32'}
   },
   [21020] = {
   },
   [21021] = {
   },
   [21022] = {
   },
   [21023] = {
      {name='package_id', type='uint32'}
   },
   [21024] = {
   },
   [21030] = {
   },
   [21031] = {
      {name='id', type='uint8'}
   },
   [21032] = {
   },
   [21033] = {
      {name='id', type='uint8'}
   },
   [21100] = {
   },
   [21101] = {
      {name='day', type='uint8'}
   },
   [21200] = {
   },
   [21201] = {
      {name='id', type='uint8'}
   },
   [21210] = {
   },
   [21211] = {
   },
   [21300] = {
   },
   [21303] = {
   },
   [21304] = {
      {name='fid', type='uint32'}
   },
   [21305] = {
   },
   [21308] = {
      {name='boss_id', type='uint32'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [21312] = {
      {name='type', type='uint8'}
   },
   [21317] = {
      {name='boss_id', type='uint32'}
   },
   [21318] = {
   },
   [21319] = {
      {name='boss_id', type='uint32'},
      {name='start_num', type='uint32'},
      {name='end_num', type='uint32'}
   },
   [21320] = {
   },
   [21321] = {
      {name='fid', type='uint32'}
   },
   [21322] = {
   },
   [21323] = {
   },
   [21401] = {
   },
   [21403] = {
   },
   [21410] = {
   },
   [21421] = {
      {name='id', type='uint8'}
   },
   [21425] = {
   },
   [21427] = {
      {name='type', type='uint8'},
      {name='num', type='uint8'}
   },
   [21500] = {
   },
   [21501] = {
      {name='base_id', type='uint32'}
   },
   [21502] = {
   },
   [21503] = {
      {name='base_id', type='uint32'}
   },
   [21504] = {
   },
   [22150] = {
   },
   [22200] = {
   },
   [22202] = {
      {name='id', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [22203] = {
      {name='id', type='uint8'}
   },
   [22204] = {
      {name='id', type='uint8'},
      {name='list1', type='array', fields={
          {name='id', type='uint32'}
      }},
      {name='list2', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [22700] = {
      {name='is_cluster', type='uint8'}
   },
   [22701] = {
      {name='id', type='uint8'}
   },
   [22702] = {
   },
   [22703] = {
   },
   [22704] = {
      {name='quest_id', type='uint32'}
   },
   [23100] = {
   },
   [23101] = {
   },
   [23102] = {
   },
   [23103] = {
      {name='index', type='uint32'}
   },
   [23104] = {
      {name='index', type='uint32'},
      {name='action', type='uint8'},
      {name='ext_list', type='array', fields={
          {name='type', type='uint8'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'}
      }}
   },
   [23105] = {
      {name='id', type='uint32'}
   },
   [23106] = {
      {name='floor', type='uint32'}
   },
   [23107] = {
   },
   [23108] = {
   },
   [23109] = {
   },
   [23110] = {
   },
   [23111] = {
   },
   [23112] = {
   },
   [23113] = {
   },
   [23114] = {
   },
   [23115] = {
   },
   [23116] = {
      {name='pos', type='uint32'}
   },
   [23117] = {
      {name='dun_id', type='uint32'}
   },
   [23118] = {
   },
   [23119] = {
   },
   [23120] = {
      {name='partner_ids', type='array', fields={
          {name='flag', type='uint8'},
          {name='id', type='uint32'}
      }}
   },
   [23121] = {
      {name='formation_type', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='flag', type='uint8'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [23122] = {
   },
   [23123] = {
      {name='type', type='uint8'}
   },
   [23200] = {
   },
   [23201] = {
      {name='group_id', type='uint16'},
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'}
   },
   [23202] = {
   },
   [23203] = {
   },
   [23204] = {
   },
   [23210] = {
   },
   [23211] = {
      {name='id', type='uint32'}
   },
   [23212] = {
   },
   [23213] = {
      {name='group_id', type='uint16'}
   },
   [23214] = {
   },
   [23215] = {
      {name='partner_id', type='uint32'},
      {name='action', type='uint8'}
   },
   [23216] = {
   },
   [23217] = {
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'}
   },
   [23218] = {
   },
   [23219] = {
      {name='bid', type='uint32'}
   },
   [23220] = {
   },
   [23221] = {
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'}
   },
   [23222] = {
   },
   [23230] = {
   },
   [23231] = {
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'}
   },
   [23232] = {
      {name='award_id', type='uint32'},
      {name='self_award_id', type='uint32'}
   },
   [23233] = {
      {name='lucky_bid', type='uint32'}
   },
   [23234] = {
   },
   [23235] = {
   },
   [23300] = {
   },
   [23301] = {
      {name='base_id', type='uint32'}
   },
   [23302] = {
   },
   [23303] = {
      {name='base_id', type='uint32'}
   },
   [23400] = {
   },
   [23402] = {
   },
   [23403] = {
      {name='id', type='uint8'}
   },
   [23500] = {
      {name='catalg', type='uint32'}
   },
   [23501] = {
      {name='base_id', type='uint32'},
      {name='num', type='uint16'}
   },
   [23502] = {
      {name='id', type='uint32'},
      {name='num', type='uint16'}
   },
   [23504] = {
      {name='package_type', type='uint8'},
      {name='item_id', type='uint32'},
      {name='num', type='uint8'},
      {name='percent', type='uint32'},
      {name='cell_id', type='uint8'}
   },
   [23505] = {
      {name='type', type='uint8'},
      {name='id', type='uint8'},
      {name='num', type='uint8'}
   },
   [23506] = {
      {name='cell_id', type='uint8'}
   },
   [23507] = {
   },
   [23508] = {
      {name='item_base_id', type='uint32'}
   },
   [23509] = {
      {name='refresh_type', type='uint8'}
   },
   [23511] = {
      {name='cell_id', type='uint8'}
   },
   [23512] = {
   },
   [23513] = {
      {name='cell_id', type='uint8'},
      {name='percent', type='uint32'},
      {name='num', type='uint8'}
   },
   [23514] = {
      {name='type', type='uint8'}
   },
   [23516] = {
      {name='base_ids', type='array', fields={
          {name='base_id', type='uint32'}
      }}
   },
   [23518] = {
      {name='catalg', type='uint32'}
   },
   [23519] = {
   },
   [23520] = {
   },
   [23601] = {
   },
   [23602] = {
   },
   [23603] = {
   },
   [23604] = {
   },
   [23606] = {
   },
   [23607] = {
      {name='id', type='uint8'}
   },
   [23700] = {
      {name='career', type='uint8'}
   },
   [23701] = {
      {name='skill_id', type='uint32'}
   },
   [23702] = {
   },
   [23703] = {
   },
   [23704] = {
      {name='career', type='uint8'}
   },
   [23705] = {
      {name='career', type='uint8'}
   },
   [23706] = {
      {name='career', type='uint8'}
   },
   [23707] = {
      {name='career', type='uint8'},
      {name='id', type='uint32'}
   },
   [23708] = {
      {name='career', type='uint8'}
   },
   [23709] = {
      {name='career', type='uint8'}
   },
   [23710] = {
      {name='career', type='uint8'}
   },
   [23711] = {
   },
   [23800] = {
   },
   [23801] = {
   },
   [23802] = {
      {name='order_id', type='uint32'},
      {name='assign_ids', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [23803] = {
      {name='order_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [23804] = {
   },
   [23805] = {
   },
   [23806] = {
   },
   [23900] = {
   },
   [23901] = {
      {name='type', type='uint8'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='owner_id', type='uint32'},
          {name='owner_srv_id', type='string'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [23902] = {
   },
   [23903] = {
      {name='type', type='uint8'}
   },
   [23904] = {
      {name='id', type='uint32'},
      {name='type', type='uint8'}
   },
   [23905] = {
   },
   [23906] = {
   },
   [23907] = {
   },
   [23908] = {
      {name='id', type='uint32'}
   },
   [23909] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='id', type='uint32'},
      {name='flag', type='uint8'}
   },
   [23910] = {
   },
   [23911] = {
      {name='buff_id', type='uint16'}
   },
   [23912] = {
   },
   [23913] = {
      {name='type', type='uint8'}
   },
   [24000] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [24001] = {
      {name='type', type='uint8'}
   },
   [24002] = {
   },
   [24003] = {
   },
   [24004] = {
   },
   [24005] = {
   },
   [24006] = {
   },
   [24010] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [24011] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [24012] = {
   },
   [24013] = {
      {name='type', type='uint8'}
   },
   [24014] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='id', type='uint32'},
      {name='type', type='uint8'}
   },
   [24015] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='id', type='uint32'}
   },
   [24017] = {
      {name='id', type='uint32'}
   },
   [24018] = {
   },
   [24019] = {
   },
   [24020] = {
   },
   [24100] = {
   },
   [24101] = {
      {name='id', type='uint32'},
      {name='is_auto', type='uint8'}
   },
   [24103] = {
      {name='hallows_id', type='uint32'}
   },
   [24104] = {
      {name='hallows_id', type='uint32'},
      {name='num', type='uint32'}
   },
   [24107] = {
   },
   [24108] = {
   },
   [24120] = {
   },
   [24121] = {
   },
   [24122] = {
      {name='id', type='uint32'}
   },
   [24123] = {
      {name='id', type='uint32'}
   },
   [24124] = {
   },
   [24125] = {
   },
   [24126] = {
   },
   [24127] = {
   },
   [24128] = {
   },
   [24129] = {
   },
   [24130] = {
      {name='id', type='uint32'}
   },
   [24131] = {
      {name='id', type='uint32'}
   },
   [24132] = {
      {name='id', type='uint32'},
      {name='hallows_id', type='uint32'},
      {name='flag', type='uint8'}
   },
   [24133] = {
   },
   [24135] = {
      {name='hallows_id', type='uint32'}
   },
   [24136] = {
      {name='r_rid', type='uint32'},
      {name='r_srvid', type='string'},
      {name='type', type='uint32'}
   },
   [24200] = {
   },
   [24201] = {
      {name='pos', type='uint32'}
   },
   [24202] = {
      {name='pos', type='uint8'},
      {name='hp', type='uint16'},
      {name='flag', type='uint8'}
   },
   [24204] = {
   },
   [24205] = {
   },
   [24206] = {
   },
   [24207] = {
   },
   [24208] = {
   },
   [24209] = {
      {name='g_id1', type='uint32'},
      {name='g_sid1', type='string'},
      {name='pos', type='uint32'}
   },
   [24210] = {
   },
   [24212] = {
   },
   [24213] = {
   },
   [24214] = {
   },
   [24220] = {
   },
   [24221] = {
      {name='order', type='uint16'}
   },
   [24223] = {
   },
   [24300] = {
   },
   [24301] = {
   },
   [24302] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [24303] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [24304] = {
   },
   [24305] = {
   },
   [24306] = {
   },
   [24308] = {
   },
   [24309] = {
   },
   [24310] = {
   },
   [24311] = {
   },
   [24312] = {
   },
   [24313] = {
   },
   [24314] = {
   },
   [24315] = {
   },
   [24316] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='pos', type='uint8'}
   },
   [24317] = {
   },
   [24318] = {
      {name='replay_id', type='uint32'},
      {name='srv_id', type='string'},
      {name='channel', type='uint16'},
      {name='target_name', type='string'}
   },
   [24400] = {
   },
   [24401] = {
      {name='id', type='uint8'}
   },
   [24402] = {
      {name='id', type='uint8'}
   },
   [24403] = {
      {name='formation_type', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='owner_id', type='uint32'},
          {name='owner_srv_id', type='string'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [24405] = {
   },
   [24406] = {
   },
   [24407] = {
      {name='id', type='uint32'}
   },
   [24408] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='id', type='uint32'}
   },
   [24409] = {
   },
   [24410] = {
   },
   [24411] = {
   },
   [24412] = {
      {name='difficulty', type='uint8'}
   },
   [24415] = {
      {name='guard_id', type='uint32'}
   },
   [24500] = {
   },
   [24501] = {
      {name='id', type='uint32'}
   },
   [24502] = {
   },
   [24600] = {
   },
   [24601] = {
   },
   [24602] = {
   },
   [24603] = {
      {name='ret_list', type='array', fields={
          {name='id', type='uint32'},
          {name='topic_type', type='uint8'},
          {name='ret', type='string'}
      }}
   },
   [24604] = {
   },
   [24700] = {
   },
   [24701] = {
      {name='id', type='uint32'}
   },
   [24702] = {
      {name='id', type='uint32'}
   },
   [24703] = {
      {name='id', type='uint16'}
   },
   [24801] = {
   },
   [24802] = {
      {name='id', type='uint8'}
   },
   [24803] = {
      {name='id', type='uint8'}
   },
   [24804] = {
   },
   [24805] = {
   },
   [24806] = {
      {name='id', type='uint32'}
   },
   [24807] = {
      {name='id', type='uint16'}
   },
   [24808] = {
   },
   [24809] = {
   },
   [24810] = {
   },
   [24811] = {
   },
   [24812] = {
      {name='id', type='uint32'}
   },
   [24813] = {
   },
   [24814] = {
      {name='id', type='uint32'}
   },
   [24815] = {
   },
   [24816] = {
      {name='id', type='uint32'}
   },
   [24817] = {
   },
   [24818] = {
      {name='id', type='uint32'}
   },
   [24900] = {
   },
   [24901] = {
   },
   [24902] = {
      {name='type', type='uint8'}
   },
   [24903] = {
   },
   [24904] = {
   },
   [24905] = {
   },
   [24906] = {
   },
   [24910] = {
   },
   [24911] = {
      {name='period', type='uint32'},
      {name='start_rank', type='uint8'},
      {name='end_rank', type='uint8'},
      {name='zone_id', type='uint32'}
   },
   [24915] = {
      {name='lev', type='uint32'}
   },
   [24920] = {
      {name='type', type='uint8'}
   },
   [24921] = {
      {name='type', type='uint8'},
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'}
      }}
   },
   [24930] = {
      {name='type', type='uint8'}
   },
   [24931] = {
      {name='type', type='uint8'},
      {name='id', type='uint32'}
   },
   [24940] = {
      {name='period', type='uint32'}
   },
   [24941] = {
      {name='channel', type='uint16'}
   },
   [24942] = {
      {name='id', type='uint32'},
      {name='share_srv_id', type='string'},
      {name='period', type='uint32'}
   },
   [24945] = {
   },
   [24946] = {
      {name='manifesto', type='array', fields={
          {name='order', type='uint8'},
          {name='manifesto_id', type='uint32'}
      }}
   },
   [24950] = {
   },
   [24951] = {
   },
   [24952] = {
   },
   [24953] = {
      {name='id', type='uint16'}
   },
   [24954] = {
   },
   [24955] = {
   },
   [25000] = {
   },
   [25001] = {
      {name='type', type='uint8'},
      {name='boss_id', type='uint32'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [25002] = {
      {name='type', type='uint8'},
      {name='boss_id', type='uint32'}
   },
   [25003] = {
   },
   [25004] = {
   },
   [25005] = {
   },
   [25100] = {
   },
   [25101] = {
      {name='id', type='uint32'}
   },
   [25200] = {
   },
   [25201] = {
      {name='id', type='uint32'}
   },
   [25203] = {
   },
   [25204] = {
   },
   [25205] = {
      {name='id', type='uint32'},
      {name='order_id', type='uint32'}
   },
   [25206] = {
   },
   [25207] = {
   },
   [25208] = {
      {name='id', type='uint32'},
      {name='order_id', type='uint32'}
   },
   [25210] = {
      {name='type', type='uint8'}
   },
   [25211] = {
      {name='type', type='uint8'},
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'}
      }}
   },
   [25215] = {
      {name='id', type='uint32'},
      {name='award_id', type='uint8'}
   },
   [25216] = {
   },
   [25217] = {
      {name='group_id', type='uint16'},
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'}
   },
   [25218] = {
      {name='type', type='uint8'},
      {name='group_id', type='uint16'}
   },
   [25219] = {
   },
   [25220] = {
   },
   [25221] = {
      {name='id', type='uint32'},
      {name='partner_id', type='uint32'},
      {name='name', type='string'},
      {name='holy_eqm', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='item_id', type='uint32'}
      }}
   },
   [25222] = {
   },
   [25223] = {
   },
   [25224] = {
      {name='partner_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [25230] = {
      {name='group_id', type='uint16'},
      {name='lucky_holy_eqm', type='array', fields={
          {name='pos', type='uint8'},
          {name='lucky_holy_eqm', type='uint32'}
      }}
   },
   [25231] = {
      {name='group_id', type='uint16'},
      {name='id', type='uint16'}
   },
   [25232] = {
   },
   [25300] = {
   },
   [25301] = {
   },
   [25302] = {
      {name='id', type='uint32'}
   },
   [25303] = {
   },
   [25304] = {
      {name='id', type='uint16'}
   },
   [25305] = {
   },
   [25306] = {
   },
   [25307] = {
      {name='id', type='uint16'}
   },
   [25308] = {
   },
   [25309] = {
   },
   [25400] = {
   },
   [25401] = {
   },
   [25402] = {
   },
   [25403] = {
   },
   [25404] = {
   },
   [25405] = {
   },
   [25410] = {
   },
   [25411] = {
   },
   [25412] = {
   },
   [25413] = {
   },
   [25414] = {
   },
   [25500] = {
   },
   [25600] = {
   },
   [25601] = {
   },
   [25602] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [25603] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='order', type='uint8'},
      {name='pos', type='uint8'}
   },
   [25604] = {
      {name='type', type='uint8'},
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'},
          {name='is_hidden', type='uint8'}
      }}
   },
   [25605] = {
      {name='type', type='uint8'}
   },
   [25606] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='is_auto', type='uint8'}
   },
   [25607] = {
   },
   [25608] = {
      {name='num', type='uint8'}
   },
   [25609] = {
   },
   [25610] = {
   },
   [25611] = {
   },
   [25612] = {
   },
   [25613] = {
      {name='pos', type='uint8'}
   },
   [25614] = {
   },
   [25615] = {
   },
   [25616] = {
      {name='type', type='uint8'}
   },
   [25617] = {
      {name='type', type='uint8'},
      {name='id', type='uint32'}
   },
   [25618] = {
   },
   [25700] = {
   },
   [25701] = {
      {name='pos', type='uint32'},
      {name='num', type='uint32'}
   },
   [25702] = {
      {name='pos', type='uint32'}
   },
   [25703] = {
   },
   [25704] = {
   },
   [25800] = {
      {name='city_id', type='uint32'}
   },
   [25801] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [25802] = {
   },
   [25805] = {
      {name='pos', type='uint8'},
      {name='id', type='uint32'}
   },
   [25806] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [25807] = {
   },
   [25810] = {
   },
   [25811] = {
   },
   [25812] = {
      {name='id', type='uint32'}
   },
   [25813] = {
      {name='id', type='uint32'}
   },
   [25814] = {
   },
   [25815] = {
      {name='id', type='uint32'},
      {name='channel', type='uint16'}
   },
   [25816] = {
      {name='share_id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [25817] = {
      {name='id', type='uint32'},
      {name='channel', type='uint16'}
   },
   [25818] = {
      {name='share_id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [25819] = {
      {name='channel', type='uint16'}
   },
   [25820] = {
      {name='share_id', type='uint32'},
      {name='srv_id', type='string'}
   },
   [25830] = {
      {name='start', type='uint16'},
      {name='num', type='uint8'}
   },
   [25831] = {
      {name='channel', type='uint16'}
   },
   [25832] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='start', type='uint16'},
      {name='num', type='uint8'}
   },
   [25833] = {
   },
   [25835] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='msg', type='string'}
   },
   [25836] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='bbs_id', type='uint32'},
      {name='msg', type='string'}
   },
   [25837] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='start', type='uint16'},
      {name='num', type='uint8'}
   },
   [25838] = {
      {name='bbs_id', type='uint32'}
   },
   [25839] = {
      {name='type', type='uint8'}
   },
   [25840] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='bbs_id', type='uint32'}
   },
   [25841] = {
   },
   [25900] = {
   },
   [25901] = {
   },
   [25910] = {
   },
   [25911] = {
   },
   [25912] = {
      {name='id', type='uint32'}
   },
   [25913] = {
   },
   [25914] = {
      {name='id', type='uint32'}
   },
   [25915] = {
   },
   [25916] = {
      {name='day', type='uint8'}
   },
   [25917] = {
   },
   [25918] = {
      {name='package_id', type='uint8'}
   },
   [25919] = {
      {name='bid', type='uint32'}
   },
   [25920] = {
   },
   [25921] = {
   },
   [26001] = {
      {name='floor', type='uint8'}
   },
   [26002] = {
      {name='wall_bid', type='uint32'},
      {name='land_bid', type='uint32'},
      {name='list', type='array', fields={
          {name='bid', type='uint32'},
          {name='index', type='uint32'},
          {name='dir', type='uint8'}
      }},
      {name='floor', type='uint8'}
   },
   [26003] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='floor', type='uint8'}
   },
   [26004] = {
   },
   [26005] = {
      {name='id', type='uint32'}
   },
   [26006] = {
      {name='id', type='uint32'}
   },
   [26007] = {
      {name='id', type='uint32'}
   },
   [26009] = {
   },
   [26010] = {
   },
   [26011] = {
      {name='name', type='string'}
   },
   [26013] = {
   },
   [26014] = {
      {name='id', type='uint32'}
   },
   [26016] = {
   },
   [26017] = {
   },
   [26018] = {
   },
   [26019] = {
   },
   [26020] = {
   },
   [26021] = {
      {name='main_floor', type='uint8'}
   },
   [26100] = {
   },
   [26101] = {
   },
   [26102] = {
      {name='name', type='string'}
   },
   [26103] = {
      {name='type', type='uint8'}
   },
   [26104] = {
   },
   [26105] = {
   },
   [26106] = {
      {name='evt_id', type='uint32'}
   },
   [26107] = {
      {name='set_item', type='array', fields={
          {name='key', type='uint8'},
          {name='id', type='uint32'}
      }}
   },
   [26108] = {
   },
   [26109] = {
   },
   [26110] = {
   },
   [26111] = {
      {name='type', type='uint8'}
   },
   [26112] = {
   },
   [26113] = {
      {name='type', type='uint8'},
      {name='id', type='uint32'}
   },
   [26200] = {
   },
   [26201] = {
   },
   [26202] = {
   },
   [26203] = {
   },
   [26204] = {
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'}
   },
   [26205] = {
   },
   [26206] = {
   },
   [26208] = {
   },
   [26209] = {
   },
   [26210] = {
   },
   [26211] = {
   },
   [26212] = {
      {name='group', type='uint8'},
      {name='pos', type='uint8'}
   },
   [26213] = {
   },
   [26214] = {
   },
   [26216] = {
   },
   [26300] = {
   },
   [26301] = {
   },
   [26400] = {
   },
   [26401] = {
      {name='pos', type='uint8'},
      {name='id', type='uint32'},
      {name='type', type='uint8'}
   },
   [26402] = {
   },
   [26410] = {
   },
   [26411] = {
      {name='all_num', type='uint32'}
   },
   [26412] = {
   },
   [26413] = {
   },
   [26414] = {
   },
   [26420] = {
   },
   [26421] = {
      {name='partner_id', type='uint32'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [26422] = {
   },
   [26423] = {
      {name='partner_id', type='uint32'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [26425] = {
   },
   [26426] = {
      {name='partner_id', type='uint32'},
      {name='pos', type='uint32'}
   },
   [26427] = {
      {name='partner_id', type='uint32'},
      {name='pos', type='uint32'}
   },
   [26428] = {
      {name='pos', type='uint32'}
   },
   [26429] = {
      {name='pos', type='uint32'},
      {name='type', type='uint32'}
   },
   [26430] = {
   },
   [26431] = {
   },
   [26432] = {
   },
   [26500] = {
   },
   [26501] = {
   },
   [26502] = {
      {name='id', type='uint8'}
   },
   [26503] = {
      {name='id', type='uint8'},
      {name='item_bid', type='uint32'}
   },
   [26504] = {
      {name='id', type='uint8'},
      {name='item_bid', type='uint32'},
      {name='item_num', type='uint32'},
      {name='type', type='uint8'}
   },
   [26505] = {
      {name='id', type='uint8'}
   },
   [26506] = {
      {name='id', type='uint8'}
   },
   [26507] = {
      {name='type', type='uint8'},
      {name='item_id', type='uint32'},
      {name='num', type='uint32'}
   },
   [26508] = {
      {name='item_bid', type='uint32'},
      {name='num', type='uint32'},
      {name='pos', type='uint8'}
   },
   [26509] = {
   },
   [26510] = {
   },
   [26511] = {
   },
   [26512] = {
   },
   [26513] = {
      {name='pos', type='uint8'},
      {name='item_bid', type='uint32'}
   },
   [26514] = {
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [26520] = {
   },
   [26521] = {
   },
   [26522] = {
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'}
   },
   [26523] = {
      {name='id', type='uint16'}
   },
   [26525] = {
   },
   [26530] = {
      {name='item_bid', type='uint32'}
   },
   [26535] = {
      {name='id', type='uint32'}
   },
   [26550] = {
   },
   [26551] = {
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'}
   },
   [26552] = {
      {name='id', type='uint16'}
   },
   [26553] = {
   },
   [26554] = {
      {name='lucky_ids', type='array', fields={
          {name='lucky_sprites_bid', type='uint32'}
      }}
   },
   [26555] = {
      {name='type', type='uint32'}
   },
   [26556] = {
   },
   [26557] = {
      {name='id', type='uint8'},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='type', type='uint32'},
      {name='team', type='uint32'}
   },
   [26558] = {
      {name='id', type='uint8'},
      {name='name', type='string'}
   },
   [26559] = {
   },
   [26560] = {
      {name='type', type='uint32'},
      {name='team', type='uint32'},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='flag', type='uint8'}
   },
   [26561] = {
      {name='type', type='uint32'},
      {name='team', type='uint32'},
      {name='id', type='uint8'}
   },
   [26562] = {
      {name='id', type='uint8'}
   },
   [26563] = {
      {name='base_id', type='uint32'},
      {name='num', type='uint32'}
   },
   [26564] = {
      {name='type', type='uint32'},
      {name='team_list', type='array', fields={
          {name='team', type='uint32'},
          {name='old_team', type='uint32'}
      }}
   },
   [26600] = {
   },
   [26601] = {
   },
   [26602] = {
   },
   [26700] = {
   },
   [26701] = {
   },
   [26702] = {
   },
   [26704] = {
      {name='count', type='uint32'}
   },
   [26705] = {
   },
   [26706] = {
      {name='id', type='uint8'}
   },
   [26707] = {
   },
   [26709] = {
   },
   [26710] = {
   },
   [26711] = {
   },
   [26712] = {
      {name='num', type='uint16'},
      {name='flag', type='uint8'}
   },
   [26800] = {
   },
   [26801] = {
      {name='boss_id', type='uint32'}
   },
   [26802] = {
      {name='boss_id', type='uint32'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [26803] = {
      {name='boss_id', type='uint32'}
   },
   [26804] = {
      {name='boss_id', type='uint32'},
      {name='number', type='uint32'}
   },
   [26805] = {
      {name='boss_id', type='uint32'}
   },
   [26806] = {
      {name='boss_id', type='uint32'},
      {name='num', type='uint32'}
   },
   [26807] = {
   },
   [26808] = {
   },
   [26809] = {
   },
   [26810] = {
   },
   [26900] = {
   },
   [26901] = {
      {name='id', type='uint32'},
      {name='quantity', type='uint32'},
      {name='storage', type='uint8'}
   },
   [26902] = {
      {name='id', type='uint32'},
      {name='quantity', type='uint32'}
   },
   [26903] = {
   },
   [26904] = {
   },
   [26905] = {
   },
   [26906] = {
   },
   [27000] = {
   },
   [27001] = {
      {name='id', type='uint32'},
      {name='num', type='uint32'}
   },
   [27002] = {
   },
   [27003] = {
      {name='red_packet_id', type='uint32'}
   },
   [27004] = {
   },
   [27005] = {
   },
   [27006] = {
   },
   [27007] = {
      {name='id', type='uint16'}
   },
   [27008] = {
   },
   [27100] = {
   },
   [27101] = {
   },
   [27102] = {
   },
   [27103] = {
      {name='id', type='uint32'},
      {name='page', type='uint32'}
   },
   [27104] = {
      {name='choice', type='uint8'}
   },
   [27200] = {
   },
   [27201] = {
      {name='name', type='string'},
      {name='limit_lev', type='uint16'},
      {name='limit_power', type='uint32'},
      {name='is_check', type='uint8'}
   },
   [27202] = {
      {name='tid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [27203] = {
   },
   [27204] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='type', type='uint8'}
   },
   [27205] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [27206] = {
   },
   [27207] = {
      {name='tid', type='uint32'},
      {name='srv_id', type='string'},
      {name='type', type='uint8'}
   },
   [27208] = {
   },
   [27210] = {
      {name='name', type='string'}
   },
   [27211] = {
   },
   [27212] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [27213] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [27215] = {
   },
   [27216] = {
      {name='do_join_list', type='array', fields={
          {name='tid', type='uint32'},
          {name='srv_id', type='string'},
          {name='order', type='uint16'}
      }}
   },
   [27220] = {
   },
   [27221] = {
   },
   [27222] = {
   },
   [27223] = {
      {name='start_rank', type='uint16'},
      {name='end_rank', type='uint16'}
   },
   [27224] = {
      {name='id', type='uint32'}
   },
   [27225] = {
      {name='limit_lev', type='uint16'},
      {name='limit_power', type='uint32'},
      {name='is_check', type='uint8'}
   },
   [27226] = {
      {name='name', type='string'}
   },
   [27227] = {
   },
   [27228] = {
   },
   [27229] = {
      {name='name', type='string'}
   },
   [27240] = {
   },
   [27241] = {
   },
   [27242] = {
      {name='pos_info', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'}
      }}
   },
   [27243] = {
   },
   [27250] = {
   },
   [27251] = {
   },
   [27252] = {
      {name='tid', type='uint32'},
      {name='srv_id', type='string'},
      {name='is_auto', type='uint8'}
   },
   [27253] = {
   },
   [27255] = {
   },
   [27256] = {
      {name='id', type='uint32'}
   },
   [27300] = {
   },
   [27301] = {
      {name='reward_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [27400] = {
   },
   [27401] = {
      {name='id', type='uint32'}
   },
   [27403] = {
      {name='type', type='uint8'},
      {name='num', type='uint32'}
   },
   [27404] = {
      {name='args', type='array', fields={
          {name='type', type='uint8'},
          {name='arg1', type='uint32'},
          {name='arg2', type='uint32'}
      }}
   },
   [27405] = {
   },
   [27406] = {
   },
   [27407] = {
      {name='type', type='uint8'},
      {name='choice', type='uint8'}
   },
   [27408] = {
      {name='id', type='uint32'}
   },
   [27409] = {
   },
   [27410] = {
      {name='id', type='uint32'}
   },
   [27500] = {
      {name='id', type='uint8'}
   },
   [27501] = {
      {name='id', type='uint8'},
      {name='boss_id', type='uint8'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [27502] = {
      {name='id', type='uint8'}
   },
   [27503] = {
      {name='id', type='uint8'},
      {name='num', type='uint8'}
   },
   [27504] = {
   },
   [27505] = {
   },
   [27506] = {
   },
   [27600] = {
   },
   [27601] = {
      {name='id', type='uint32'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }}
   },
   [27602] = {
      {name='id', type='uint32'}
   },
   [27603] = {
      {name='id', type='uint32'}
   },
   [27700] = {
   },
   [27701] = {
   },
   [27702] = {
   },
   [27703] = {
   },
   [27704] = {
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'}
   },
   [27705] = {
   },
   [27706] = {
   },
   [27707] = {
   },
   [27708] = {
   },
   [27709] = {
      {name='zone_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [27710] = {
      {name='zone_id', type='uint32'}
   },
   [27711] = {
   },
   [27712] = {
      {name='zone_id', type='uint32'},
      {name='type', type='uint8'},
      {name='group', type='uint8'},
      {name='pos', type='uint8'}
   },
   [27713] = {
      {name='zone_id', type='uint32'},
      {name='period', type='uint32'}
   },
   [27714] = {
      {name='zone_id', type='uint32'},
      {name='start_num', type='uint32'},
      {name='end_num', type='uint32'}
   },
   [27720] = {
   },
   [27725] = {
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'}
      }}
   },
   [27726] = {
   },
   [27730] = {
   },
   [27731] = {
      {name='type', type='uint8'}
   },
   [27800] = {
   },
   [27801] = {
      {name='package_id', type='uint32'}
   },
   [27900] = {
   },
   [27901] = {
   },
   [27902] = {
   },
   [27903] = {
   },
   [27904] = {
      {name='type', type='uint8'}
   },
   [27905] = {
   },
   [27906] = {
   },
   [27907] = {
      {name='id', type='uint32'}
   },
   [27908] = {
   },
   [27909] = {
      {name='day', type='uint16'}
   },
   [27910] = {
   },
   [27911] = {
      {name='red_packet_id', type='uint32'}
   },
   [27912] = {
   },
   [27913] = {
   },
   [27914] = {
   },
   [27915] = {
      {name='id', type='uint32'}
   },
   [27916] = {
   },
   [28000] = {
   },
   [28100] = {
   },
   [28101] = {
   },
   [28102] = {
   },
   [28103] = {
   },
   [28200] = {
   },
   [28201] = {
   },
   [28202] = {
      {name='index', type='uint32'}
   },
   [28203] = {
      {name='index', type='uint32'},
      {name='action', type='uint8'},
      {name='ext_list', type='array', fields={
          {name='type', type='uint8'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'}
      }}
   },
   [28204] = {
   },
   [28205] = {
   },
   [28206] = {
   },
   [28207] = {
   },
   [28208] = {
   },
   [28209] = {
   },
   [28210] = {
   },
   [28211] = {
      {name='num', type='uint32'}
   },
   [28212] = {
      {name='type', type='uint8'}
   },
   [28213] = {
      {name='type', type='uint8'},
      {name='num', type='uint8'}
   },
   [28214] = {
   },
   [28215] = {
   },
   [28216] = {
      {name='id', type='uint32'},
      {name='num', type='uint32'}
   },
   [28217] = {
   },
   [28218] = {
   },
   [28219] = {
      {name='face', type='array', fields={
          {name='order', type='uint8'},
          {name='face_id', type='uint32'}
      }}
   },
   [28220] = {
   },
   [28221] = {
   },
   [28222] = {
   },
   [28223] = {
   },
   [28224] = {
   },
   [28300] = {
   },
   [28301] = {
   },
   [28302] = {
      {name='pos', type='uint32'}
   },
   [28303] = {
   },
   [28305] = {
      {name='type_id', type='uint32'}
   },
   [28306] = {
   },
   [28307] = {
   },
   [28308] = {
   },
   [28400] = {
   },
   [28401] = {
      {name='period', type='uint8'}
   },
   [28402] = {
   },
   [28403] = {
   },
   [28500] = {
   },
   [28501] = {
      {name='reward_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [28502] = {
      {name='id', type='uint32'},
      {name='num', type='uint32'}
   },
   [28600] = {
      {name='line', type='uint32'},
      {name='index', type='uint32'},
      {name='action', type='uint8'},
      {name='ext_list', type='array', fields={
          {name='type', type='uint8'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'}
      }}
   },
   [28601] = {
   },
   [28602] = {
   },
   [28603] = {
   },
   [28604] = {
      {name='floor', type='uint32'},
      {name='difficulty', type='uint8'}
   },
   [28605] = {
      {name='floor', type='uint32'}
   },
   [28606] = {
   },
   [28607] = {
   },
   [28608] = {
   },
   [28609] = {
   },
   [28610] = {
      {name='partner_ids', type='array', fields={
          {name='flag', type='uint8'},
          {name='id', type='uint32'}
      }}
   },
   [28611] = {
      {name='formation_type', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='flag', type='uint8'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [28612] = {
   },
   [28613] = {
   },
   [28614] = {
   },
   [28615] = {
   },
   [28616] = {
   },
   [28617] = {
      {name='id', type='uint16'}
   },
   [28618] = {
   },
   [28619] = {
   },
   [28620] = {
   },
   [28621] = {
   },
   [28622] = {
   },
   [28623] = {
      {name='pos', type='uint32'}
   },
   [28624] = {
   },
   [28625] = {
   },
   [28626] = {
   },
   [28700] = {
   },
   [28701] = {
   },
   [28702] = {
      {name='id', type='uint32'}
   },
   [28703] = {
   },
   [28704] = {
      {name='id', type='uint16'}
   },
   [28705] = {
   },
   [28706] = {
   },
   [28707] = {
   },
   [28708] = {
   },
   [28800] = {
   },
   [28801] = {
      {name='id', type='uint32'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [28802] = {
   },
   [28803] = {
   },
   [28900] = {
   },
   [28901] = {
   },
   [29000] = {
   },
   [29001] = {
      {name='name', type='string'}
   },
   [29002] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [29003] = {
   },
   [29004] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='type', type='uint8'}
   },
   [29005] = {
   },
   [29006] = {
   },
   [29007] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [29008] = {
   },
   [29009] = {
   },
   [29010] = {
   },
   [29016] = {
   },
   [29017] = {
   },
   [29018] = {
   },
   [29019] = {
      {name='pos_info', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='pos', type='uint16'}
      }}
   },
   [29020] = {
   },
   [29021] = {
   },
   [29022] = {
      {name='pos_info', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='pos', type='uint16'}
      }}
   },
   [29025] = {
      {name='start_num', type='uint32'},
      {name='end_num', type='uint32'}
   },
   [29026] = {
   },
   [29027] = {
      {name='id', type='uint32'}
   },
   [29028] = {
   },
   [29030] = {
   },
   [29031] = {
      {name='id', type='uint32'}
   },
   [29035] = {
   },
   [29100] = {
   },
   [29101] = {
      {name='id', type='uint32'},
      {name='formation_type', type='uint16'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [29102] = {
   },
   [29103] = {
   },
   [29104] = {
   },
   [29105] = {
   },
   [29106] = {
   },
   [29107] = {
      {name='type', type='uint8'}
   }
}

-- 接收解包协议
Proto.recv = {
   [10101] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='reg_time', type='uint32'}
   },
   [10102] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='timestamp', type='uint32'},
      {name='world_lev', type='uint16'}
   },
   [10103] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='timestamp', type='uint32'},
      {name='world_lev', type='uint16'}
   },
   [10200] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='battle_id', type='uint32'},
      {name='id', type='uint32'},
      {name='time', type='uint32'}
   },
   [10210] = {
      {name='bid', type='uint32'},
      {name='res_id', type='uint32'},
      {name='x', type='uint16'},
      {name='y', type='uint16'},
      {name='dir', type='uint8'}
   },
   [10211] = {
      {name='bid', type='uint32'},
      {name='dynamic_block', type='array', fields={
          {name='id', type='uint8'},
          {name='val', type='uint8'}
      }}
   },
   [10213] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='speed', type='uint16'},
      {name='dir', type='uint8'},
      {name='x', type='uint16'},
      {name='y', type='uint16'},
      {name='face', type='uint32'},
      {name='lev', type='uint8'},
      {name='sex', type='uint8'},
      {name='avatar', type='uint32'},
      {name='status', type='uint8'},
      {name='event', type='uint8'},
      {name='looks', type='array', fields={
          {name='looks_type', type='uint32'},
          {name='looks_mode', type='uint32'},
          {name='looks_val', type='uint32'},
          {name='looks_str', type='string'}
      }}
   },
   [10214] = {
      {name='bid', type='uint32'},
      {name='role_ids', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [10215] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='dir', type='uint8'},
      {name='dx', type='uint16'},
      {name='dy', type='uint16'}
   },
   [10216] = {
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='speed', type='uint16'},
          {name='dir', type='uint8'},
          {name='x', type='uint16'},
          {name='y', type='uint16'},
          {name='face', type='uint32'},
          {name='lev', type='uint8'},
          {name='sex', type='uint8'},
          {name='avatar', type='uint32'},
          {name='status', type='uint8'},
          {name='event', type='uint8'},
          {name='looks', type='array', fields={
              {name='looks_type', type='uint32'},
              {name='looks_mode', type='uint32'},
              {name='looks_val', type='uint32'},
              {name='looks_str', type='string'}
          }}
      }}
   },
   [10217] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='speed', type='uint16'},
      {name='dir', type='uint8'},
      {name='x', type='uint16'},
      {name='y', type='uint16'},
      {name='face', type='uint32'},
      {name='lev', type='uint8'},
      {name='sex', type='uint8'},
      {name='avatar', type='uint32'},
      {name='status', type='uint8'},
      {name='event', type='uint8'},
      {name='looks', type='array', fields={
          {name='looks_type', type='uint32'},
          {name='looks_mode', type='uint32'},
          {name='looks_val', type='uint32'},
          {name='looks_str', type='string'}
      }}
   },
   [10219] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='type', type='uint8'},
      {name='looks', type='array', fields={
          {name='looks_type', type='uint32'},
          {name='looks_mode', type='uint32'},
          {name='looks_val', type='uint32'},
          {name='looks_str', type='string'}
      }}
   },
   [10220] = {
      {name='unit_list', type='array', fields={
          {name='battle_id', type='uint32'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='name', type='string'},
          {name='status', type='uint8'},
          {name='speed', type='uint16'},
          {name='x', type='uint16'},
          {name='y', type='uint16'},
          {name='lev', type='uint8'},
          {name='looks', type='array', fields={
              {name='looks_type', type='uint32'},
              {name='looks_mode', type='uint32'},
              {name='looks_val', type='uint32'},
              {name='looks_str', type='string'}
          }}
      }}
   },
   [10222] = {
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='speed', type='uint16'},
          {name='dir', type='uint8'},
          {name='x', type='uint16'},
          {name='y', type='uint16'},
          {name='face', type='uint32'},
          {name='lev', type='uint8'},
          {name='sex', type='uint8'},
          {name='avatar', type='uint32'},
          {name='status', type='uint8'},
          {name='event', type='uint8'},
          {name='looks', type='array', fields={
              {name='looks_type', type='uint32'},
              {name='looks_mode', type='uint32'},
              {name='looks_val', type='uint32'},
              {name='looks_str', type='string'}
          }}
      }}
   },
   [10250] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='act_type', type='uint32'},
      {name='num', type='uint8'}
   },
   [10260] = {
      {name='battle_id', type='uint32'},
      {name='id', type='uint32'},
      {name='base_id', type='uint32'},
      {name='name', type='string'},
      {name='status', type='uint8'},
      {name='speed', type='uint16'},
      {name='x', type='uint16'},
      {name='y', type='uint16'},
      {name='lev', type='uint8'},
      {name='looks', type='array', fields={
          {name='looks_type', type='uint32'},
          {name='looks_mode', type='uint32'},
          {name='looks_val', type='uint32'},
          {name='looks_str', type='string'}
      }}
   },
   [10262] = {
      {name='battle_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [10264] = {
      {name='battle_id', type='uint32'},
      {name='id', type='uint32'},
      {name='dx', type='uint16'},
      {name='dy', type='uint16'}
   },
   [10265] = {
      {name='battle_id', type='uint32'},
      {name='id', type='uint32'},
      {name='msg', type='string'}
   },
   [10266] = {
      {name='battle_id', type='uint32'},
      {name='id', type='uint32'},
      {name='base_id', type='uint32'},
      {name='name', type='string'},
      {name='status', type='uint8'},
      {name='speed', type='uint16'},
      {name='x', type='uint16'},
      {name='y', type='uint16'},
      {name='lev', type='uint8'},
      {name='looks', type='array', fields={
          {name='looks_type', type='uint32'},
          {name='looks_mode', type='uint32'},
          {name='looks_val', type='uint32'},
          {name='looks_str', type='string'}
      }}
   },
   [10300] = {
   },
   [10301] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint16'},
      {name='is_vip', type='uint8'},
      {name='vip_lev', type='uint8'},
      {name='vip_exp', type='uint32'},
      {name='is_show_vip', type='uint8'},
      {name='sex', type='uint8'},
      {name='career', type='uint16'},
      {name='face_id', type='uint32'},
      {name='event', type='uint8'},
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='position', type='uint8'},
      {name='gname', type='string'},
      {name='signature', type='string'},
      {name='exp_max', type='uint32'},
      {name='exp_total_nextlev', type='uint32'},
      {name='buffs', type='array', fields={
          {name='bid', type='uint32'},
          {name='duration', type='uint32'},
          {name='count', type='uint8'},
          {name='effect', type='array', fields={
              {name='key', type='uint8'},
              {name='val', type='uint32'}
          }}
      }},
      {name='reg_time', type='uint32'},
      {name='guild_lev', type='uint8'},
      {name='power', type='uint32'},
      {name='is_first_rename', type='uint8'},
      {name='avatar_base_id', type='uint32'},
      {name='guild_quit_time', type='uint32'},
      {name='look_id', type='uint32'},
      {name='max_power', type='uint32'},
      {name='auto_pk', type='uint8'},
      {name='fans_num', type='uint32'},
      {name='arena_elite_lev', type='uint32'},
      {name='city_id', type='uint32'},
      {name='room_bbs_set', type='uint8'},
      {name='backdrop_id', type='uint32'},
      {name='is_open_home', type='uint8'},
      {name='sprite_lev', type='uint16'},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='face_file', type='string'},
      {name='face_update_time', type='uint32'}
   },
   [10302] = {
      {name='lev', type='uint16'},
      {name='exp', type='uint32'},
      {name='gold', type='uint32'},
      {name='gold_acc', type='uint32'},
      {name='coin', type='uint32'},
      {name='red_gold', type='uint32'},
      {name='energy', type='uint32'},
      {name='energy_max', type='uint32'},
      {name='arena_cent', type='uint32'},
      {name='activity', type='uint16'},
      {name='guild', type='uint32'},
      {name='hero_soul', type='uint32'},
      {name='friend_point', type='uint32'},
      {name='boss_point', type='uint32'},
      {name='silver_coin', type='uint32'},
      {name='star_hun', type='uint32'},
      {name='star_point', type='uint32'},
      {name='arena_guesscent', type='uint32'},
      {name='sky_coin', type='uint32'},
      {name='hero_exp', type='uint32'},
      {name='recruit_hero', type='uint32'},
      {name='recruithigh_hero', type='uint32'},
      {name='expedition_medal', type='uint32'},
      {name='elite_coin', type='uint32'},
      {name='holy_eqm_coin', type='uint32'},
      {name='skin_debris', type='uint32'},
      {name='cluster_coin', type='uint32'},
      {name='home_coin', type='uint32'},
      {name='hallow_refine', type='uint32'},
      {name='cluster_guess_cent', type='uint32'},
      {name='feather_exchange', type='uint32'},
      {name='brave_symbol', type='uint32'},
      {name='peak_guess_cent', type='uint32'},
      {name='acc_recruit_hero', type='uint32'},
      {name='predict_point', type='uint32'}
   },
   [10304] = {
      {name='play_video', type='uint8'}
   },
   [10305] = {
      {name='assets', type='array', fields={
          {name='label', type='uint8'},
          {name='val', type='uint32'}
      }}
   },
   [10306] = {
      {name='power', type='uint32'},
      {name='max_power', type='uint32'}
   },
   [10307] = {
      {name='event', type='uint8'}
   },
   [10309] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='signature', type='string'}
   },
   [10310] = {
      {name='is_show', type='uint8'},
      {name='msg', type='string'}
   },
   [10312] = {
   },
   [10315] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='gname', type='string'},
      {name='lev', type='uint16'},
      {name='face_id', type='uint32'},
      {name='power', type='uint32'},
      {name='elite_lev', type='uint32'},
      {name='partner_list', type='array', fields={
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='awaken_lev', type='uint32'},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint8'},
          {name='resonate_lev', type='uint32'}
      }},
      {name='room_partner_list', type='array', fields={
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='awaken_lev', type='uint32'},
          {name='use_skin', type='uint32'},
          {name='pos', type='uint8'},
          {name='end_time', type='uint8'},
          {name='resonate_lev', type='uint32'}
      }},
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='avatar_bid', type='uint32'},
      {name='sex', type='uint8'},
      {name='city', type='uint32'},
      {name='vip_lev', type='uint32'},
      {name='is_show_vip', type='uint8'},
      {name='honor_list', type='array', fields={
          {name='type', type='uint32'},
          {name='val', type='uint32'},
          {name='rank', type='uint8'}
      }},
      {name='is_friend', type='uint8'},
      {name='is_fanse', type='uint8'},
      {name='is_be_fanse', type='uint8'},
      {name='fans_num', type='uint32'},
      {name='fans_rank', type='uint32'},
      {name='city_id', type='uint32'},
      {name='honor', type='uint32'},
      {name='use_badges', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='time', type='uint32'}
      }},
      {name='room_bbs_set', type='uint8'},
      {name='backdrop_id', type='uint32'},
      {name='is_open_home', type='uint8'},
      {name='sprite_lev', type='uint16'},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='face_file', type='string'},
      {name='face_update_time', type='uint32'}
   },
   [10316] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='idx', type='uint32'}
   },
   [10317] = {
      {name='worship', type='uint32'}
   },
   [10318] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='auto_pk', type='uint8'}
   },
   [10319] = {
      {name='worship', type='uint32'}
   },
   [10320] = {
      {name='worship', type='uint32'}
   },
   [10322] = {
      {name='code1', type='uint8'}
   },
   [10323] = {
      {name='code', type='uint8'}
   },
   [10325] = {
      {name='face_list', type='array', fields={
          {name='face_id', type='uint32'}
      }}
   },
   [10327] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='face_id', type='uint32'}
   },
   [10328] = {
      {name='backdrop_list', type='array', fields={
          {name='backdrop_id', type='uint32'}
      }}
   },
   [10329] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='backdrop_id', type='uint32'}
   },
   [10330] = {
      {name='secret_id', type='string'},
      {name='secret_key', type='string'},
      {name='face_file', type='string'}
   },
   [10332] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='face_file', type='string'},
      {name='face_update_time', type='uint32'}
   },
   [10333] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='face_file', type='string'},
      {name='face_update_time', type='uint32'}
   },
   [10342] = {
   },
   [10343] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='name', type='string'},
      {name='sex', type='uint8'},
      {name='is_first_rename', type='uint8'}
   },
   [10344] = {
      {name='old_lev', type='uint16'},
      {name='lev', type='uint16'}
   },
   [10345] = {
      {name='use_id', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [10346] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [10347] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [10348] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='is_show_vip', type='uint8'}
   },
   [10350] = {
      {name='holiday_assets', type='array', fields={
          {name='id', type='uint32'},
          {name='val', type='uint32'}
      }}
   },
   [10351] = {
      {name='holiday_assets', type='array', fields={
          {name='id', type='uint32'},
          {name='val', type='uint32'}
      }}
   },
   [10360] = {
      {name='ids', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [10380] = {
      {name='reg_time', type='uint32'},
      {name='open_time', type='uint32'}
   },
   [10391] = {
      {name='type', type='uint8'},
      {name='data', type='string'}
   },
   [10392] = {
   },
   [10394] = {
   },
   [10395] = {
      {name='status', type='uint8'},
      {name='end_time', type='uint32'},
      {name='down_sec', type='uint32'}
   },
   [10396] = {
   },
   [10397] = {
   },
   [10399] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10400] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='accept_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='int16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint8'},
                  {name='value', type='uint32'}
              }}
          }}
      }}
   },
   [10402] = {
      {name='flag', type='int8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [10403] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='accept_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='int16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint8'},
                  {name='value', type='uint32'}
              }}
          }}
      }}
   },
   [10404] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [10405] = {
      {name='flag', type='int8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [10406] = {
      {name='flag', type='int8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [10407] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [10408] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [10409] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='accept_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='int16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint8'},
                  {name='value', type='uint32'}
              }}
          }}
      }}
   },
   [10500] = {
      {name='volume', type='uint32'},
      {name='open_times', type='uint8'},
      {name='item_list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='bind', type='uint8'},
          {name='quantity', type='uint32'},
          {name='pos', type='uint16'},
          {name='expire_type', type='uint8'},
          {name='expire_time', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='score', type='uint32'},
          {name='all_score', type='uint32'},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }}
   },
   [10501] = {
      {name='volume', type='uint32'},
      {name='open_times', type='uint8'},
      {name='item_list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='bind', type='uint8'},
          {name='quantity', type='uint32'},
          {name='pos', type='uint16'},
          {name='expire_type', type='uint8'},
          {name='expire_time', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='score', type='uint32'},
          {name='all_score', type='uint32'},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }},
          {name='gemstones', type='array', fields={
              {name='lev', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }}
      }}
   },
   [10502] = {
      {name='volume', type='uint32'},
      {name='open_times', type='uint8'},
      {name='item_list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='bind', type='uint8'},
          {name='quantity', type='uint32'},
          {name='pos', type='uint16'},
          {name='expire_type', type='uint8'},
          {name='expire_time', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='score', type='uint32'},
          {name='all_score', type='uint32'},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }}
   },
   [10503] = {
      {name='volume', type='uint32'},
      {name='open_times', type='uint8'},
      {name='item_list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='bind', type='uint8'},
          {name='quantity', type='uint32'},
          {name='pos', type='uint16'},
          {name='expire_type', type='uint8'},
          {name='expire_time', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='score', type='uint32'},
          {name='all_score', type='uint32'},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }}
   },
   [10510] = {
      {name='item_list', type='array', fields={
          {name='storage', type='uint8'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='bind', type='uint8'},
          {name='quantity', type='uint32'},
          {name='pos', type='uint16'},
          {name='expire_type', type='uint8'},
          {name='expire_time', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='score', type='uint32'},
          {name='all_score', type='uint32'},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }},
          {name='gemstones', type='array', fields={
              {name='lev', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }}
      }}
   },
   [10511] = {
      {name='item_list', type='array', fields={
          {name='storage', type='uint8'},
          {name='id', type='uint32'},
          {name='pos', type='uint16'}
      }}
   },
   [10512] = {
      {name='item_list', type='array', fields={
          {name='storage', type='uint8'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='bind', type='uint8'},
          {name='quantity', type='uint32'},
          {name='pos', type='uint16'},
          {name='expire_type', type='uint8'},
          {name='expire_time', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='score', type='uint32'},
          {name='all_score', type='uint32'},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }},
          {name='gemstones', type='array', fields={
              {name='lev', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }}
      }}
   },
   [10515] = {
      {name='flag', type='uint8'},
      {name='base_id', type='uint32'},
      {name='msg', type='string'}
   },
   [10520] = {
      {name='id', type='uint32'},
      {name='storage', type='uint8'},
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [10521] = {
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [10522] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [10523] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [10524] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [10525] = {
      {name='star_list', type='array', fields={
          {name='star', type='uint8'}
      }}
   },
   [10526] = {
      {name='type', type='uint8'},
      {name='volume', type='uint32'},
      {name='open_times', type='uint8'}
   },
   [10528] = {
      {name='time', type='uint32'},
      {name='minu_exp', type='uint32'}
   },
   [10530] = {
   },
   [10535] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='share_id', type='uint32'},
      {name='base_id', type='uint32'},
      {name='count', type='uint32'},
      {name='code', type='uint32'}
   },
   [10536] = {
      {name='base_id', type='uint32'},
      {name='quantity', type='uint32'},
      {name='pos', type='uint16'},
      {name='expire_type', type='uint8'},
      {name='expire_time', type='uint32'},
      {name='main_attr', type='array', fields={
          {name='attr_id', type='uint32'},
          {name='attr_val', type='uint32'}
      }},
      {name='enchant', type='uint32'},
      {name='attr', type='array', fields={
          {name='attr_id', type='uint32'},
          {name='attr_val', type='uint32'}
      }},
      {name='score', type='uint32'},
      {name='all_score', type='uint32'},
      {name='extra', type='array', fields={
          {name='extra_k', type='uint32'},
          {name='extra_v', type='uint32'}
      }},
      {name='gemstones', type='array', fields={
          {name='lev', type='uint32'}
      }}
   },
   [10800] = {
      {name='mail', type='array', fields={
          {name='id', type='uint32'},
          {name='srv_id', type='string'},
          {name='type', type='uint8'},
          {name='from_name', type='string'},
          {name='subject', type='string'},
          {name='send_time', type='uint32'},
          {name='read_time', type='uint32'},
          {name='time_out', type='uint32'},
          {name='status', type='uint8'},
          {name='has_items', type='uint8'}
      }}
   },
   [10801] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'},
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10802] = {
      {name='ids', type='array', fields={
          {name='id', type='uint32'},
          {name='srv_id', type='string'},
          {name='read_time', type='uint32'}
      }},
      {name='msg', type='string'}
   },
   [10803] = {
      {name='mail', type='array', fields={
          {name='id', type='uint32'},
          {name='srv_id', type='string'},
          {name='type', type='uint8'},
          {name='from_name', type='string'},
          {name='subject', type='string'},
          {name='send_time', type='uint32'},
          {name='read_time', type='uint32'},
          {name='time_out', type='uint32'},
          {name='status', type='uint8'},
          {name='has_items', type='uint8'}
      }}
   },
   [10804] = {
      {name='ids', type='array', fields={
          {name='id', type='uint32'},
          {name='srv_id', type='string'}
      }},
      {name='msg', type='string'}
   },
   [10805] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'},
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='read_time', type='uint32'},
      {name='is_delete', type='uint8'}
   },
   [10806] = {
      {name='id', type='uint32'},
      {name='srv_id', type='string'},
      {name='type', type='uint8'},
      {name='from_name', type='string'},
      {name='subject', type='string'},
      {name='content', type='string'},
      {name='assets', type='array', fields={
          {name='label', type='uint8'},
          {name='val', type='uint32'}
      }},
      {name='items', type='array', fields={
          {name='base_id', type='uint32'},
          {name='quantity', type='uint32'}
      }},
      {name='send_time', type='uint32'},
      {name='read_time', type='uint32'},
      {name='time_out', type='uint32'},
      {name='status', type='uint8'}
   },
   [10810] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [10811] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10813] = {
      {name='feedback_logs', type='array', fields={
          {name='id', type='uint32'},
          {name='title', type='string'},
          {name='content', type='string'},
          {name='state', type='uint8'},
          {name='status2', type='uint8'},
          {name='end_msg_time', type='uint32'},
          {name='start_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='score_time', type='uint32'}
      }}
   },
   [10814] = {
      {name='id', type='uint32'},
      {name='title', type='string'},
      {name='content', type='string'},
      {name='state', type='uint8'},
      {name='status2', type='uint8'},
      {name='end_msg_time', type='uint32'},
      {name='start_time', type='uint32'},
      {name='finish_time', type='uint32'},
      {name='score_time', type='uint32'},
      {name='questions_lists', type='array', fields={
          {name='questions_timer', type='uint32'},
          {name='questions_content', type='string'}
      }},
      {name='answer_lists', type='array', fields={
          {name='answer_timer', type='uint32'},
          {name='answer_content', type='string'}
      }}
   },
   [10900] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10901] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10902] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10905] = {
      {name='world_lev', type='uint8'}
   },
   [10906] = {
      {name='open_day', type='uint32'}
   },
   [10907] = {
      {name='sys_ban', type='uint8'}
   },
   [10911] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='buffs', type='array', fields={
          {name='bid', type='uint32'},
          {name='duration', type='uint32'},
          {name='count', type='uint8'},
          {name='effect', type='array', fields={
              {name='key', type='uint8'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [10912] = {
      {name='bid', type='uint32'},
      {name='effect', type='array', fields={
          {name='key', type='uint8'},
          {name='val', type='uint32'}
      }}
   },
   [10913] = {
      {name='buffs', type='array', fields={
          {name='change_type', type='uint8'},
          {name='bid', type='uint32'},
          {name='duration', type='uint32'},
          {name='count', type='uint8'},
          {name='effect', type='array', fields={
              {name='key', type='uint8'},
              {name='val', type='int32'}
          }}
      }}
   },
   [10922] = {
      {name='act_list', type='array', fields={
          {name='id', type='uint16'},
          {name='status', type='uint8'},
          {name='int_args', type='array', fields={
              {name='val', type='uint32'}
          }},
          {name='ext_args', type='array', fields={
              {name='type', type='uint8'},
              {name='val', type='uint32'},
              {name='str', type='string'}
          }}
      }}
   },
   [10923] = {
      {name='id', type='uint16'},
      {name='status', type='uint8'},
      {name='int_args', type='array', fields={
          {name='val', type='uint32'}
      }},
      {name='ext_args', type='array', fields={
          {name='type', type='uint8'},
          {name='val', type='uint32'},
          {name='str', type='string'}
      }}
   },
   [10924] = {
      {name='act_list', type='array', fields={
          {name='id', type='uint16'},
          {name='status', type='uint8'},
          {name='int_args', type='array', fields={
              {name='val', type='uint32'}
          }},
          {name='ext_args', type='array', fields={
              {name='type', type='uint8'},
              {name='val', type='uint32'},
              {name='str', type='string'}
          }}
      }}
   },
   [10925] = {
      {name='id', type='uint16'},
      {name='status', type='uint8'},
      {name='int_args', type='array', fields={
          {name='val', type='uint32'}
      }},
      {name='ext_args', type='array', fields={
          {name='type', type='uint8'},
          {name='val', type='uint32'},
          {name='str', type='string'}
      }}
   },
   [10926] = {
      {name='time', type='uint32'},
      {name='list', type='array', fields={
          {name='time', type='uint32'}
      }}
   },
   [10927] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='time', type='uint32'}
   },
   [10928] = {
      {name='code', type='uint8'}
   },
   [10929] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10930] = {
      {name='code', type='uint8'},
      {name='open_timestamp', type='uint32'}
   },
   [10931] = {
      {name='code', type='uint8'}
   },
   [10945] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10946] = {
      {name='code', type='uint8'}
   },
   [10947] = {
      {name='code', type='uint8'},
      {name='url', type='string'}
   },
   [10950] = {
      {name='type', type='uint8'},
      {name='board_list', type='array', fields={
          {name='id', type='uint32'},
          {name='type', type='uint8'},
          {name='title', type='string'},
          {name='summary', type='string'},
          {name='content', type='string'},
          {name='start_time', type='uint32'},
          {name='end_time', type='uint32'},
          {name='flag', type='uint8'}
      }}
   },
   [10951] = {
      {name='id', type='uint32'}
   },
   [10952] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [10955] = {
      {name='key', type='uint16'},
      {name='val', type='uint32'}
   },
   [10956] = {
   },
   [10957] = {
   },
   [10958] = {
   },
   [10960] = {
      {name='code', type='uint8'}
   },
   [10961] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [10971] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='token', type='string'}
   },
   [10985] = {
      {name='id_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [10986] = {
   },
   [10987] = {
      {name='is_point', type='uint8'}
   },
   [10988] = {
   },
   [10989] = {
      {name='id', type='uint32'},
      {name='start_unixtime', type='uint32'}
   },
   [10990] = {
      {name='flag', type='uint8'},
      {name='cmd', type='uint32'},
      {name='img', type='byte'}
   },
   [10991] = {
      {name='status', type='uint8'},
      {name='is_vote', type='uint8'},
      {name='flag', type='uint8'},
      {name='last_time', type='uint32'}
   },
   [10992] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='agreepoints', type='uint32'},
      {name='disagreepoints', type='uint32'},
      {name='id', type='uint8'}
   },
   [10993] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [10994] = {
      {name='type', type='uint8'}
   },
   [10995] = {
      {name='main_srv_id', type='string'},
      {name='srv_list', type='array', fields={
          {name='srv_id', type='string'}
      }}
   },
   [10996] = {
      {name='cli_ver_list', type='array', fields={
          {name='cdn_patch', type='string'},
          {name='cli_ver', type='uint16'}
      }}
   },
   [10997] = {
      {name='flag', type='uint8'}
   },
   [10999] = {
   },
   [1110] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='roles', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='career', type='uint16'},
          {name='face_id', type='uint32'},
          {name='is_online', type='uint8'}
      }},
      {name='least_career', type='uint8'}
   },
   [1190] = {
   },
   [1196] = {
      {name='time', type='uint32'}
   },
   [1197] = {
   },
   [1198] = {
      {name='time', type='uint32'}
   },
   [1199] = {
      {name='time', type='uint32'}
   },
   [11000] = {
      {name='sort_type', type='uint8'},
      {name='num', type='uint32'},
      {name='buy_num', type='uint8'},
      {name='partners', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='skills', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_bid', type='uint32'}
          }},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='is_lock', type='array', fields={
              {name='lock_type', type='uint32'},
              {name='is_lock', type='uint8'}
          }},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint32'},
          {name='resonate_lev', type='uint32'},
          {name='resonate_break_lev', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'},
          {name='atk2', type='uint32'},
          {name='hp2', type='uint32'},
          {name='def2', type='uint32'},
          {name='speed2', type='uint32'},
          {name='eqms', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'}
          }},
          {name='artifacts', type='array', fields={
              {name='artifact_pos', type='uint8'},
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='enchant', type='uint32'},
              {name='attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }},
          {name='dower_skill', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_id', type='uint32'}
          }}
      }}
   },
   [11001] = {
      {name='partners', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='skills', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_bid', type='uint32'}
          }},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='is_lock', type='array', fields={
              {name='lock_type', type='uint32'},
              {name='is_lock', type='uint8'}
          }},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint32'},
          {name='resonate_lev', type='uint32'},
          {name='resonate_break_lev', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'},
          {name='atk2', type='uint32'},
          {name='hp2', type='uint32'},
          {name='def2', type='uint32'},
          {name='speed2', type='uint32'},
          {name='eqms', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'}
          }},
          {name='artifacts', type='array', fields={
              {name='artifact_pos', type='uint8'},
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='enchant', type='uint32'},
              {name='attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }},
          {name='dower_skill', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_id', type='uint32'}
          }}
      }}
   },
   [11002] = {
      {name='partner_id', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_bid', type='uint32'}
      }},
      {name='break_lev', type='uint8'},
      {name='power', type='uint32'},
      {name='is_lock', type='array', fields={
          {name='lock_type', type='uint32'},
          {name='is_lock', type='uint8'}
      }},
      {name='use_skin', type='uint32'},
      {name='end_time', type='uint32'},
      {name='resonate_lev', type='uint32'},
      {name='resonate_break_lev', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='def', type='uint32'},
      {name='atk2', type='uint32'},
      {name='hp2', type='uint32'},
      {name='def2', type='uint32'},
      {name='speed2', type='uint32'}
   },
   [11003] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11004] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11005] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11006] = {
      {name='expend2', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11007] = {
      {name='ref_partners', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='power', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'}
      }}
   },
   [11008] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='partners', type='array', fields={
          {name='partner_bid', type='uint32'}
      }}
   },
   [11009] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='num', type='uint32'},
      {name='buy_num', type='uint8'}
   },
   [11010] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11011] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11012] = {
      {name='partner_id', type='uint32'},
      {name='power', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='def', type='uint32'},
      {name='eqms', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='type', type='uint32'}
      }}
   },
   [11015] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='partner_id', type='uint32'},
      {name='type', type='uint8'}
   },
   [11016] = {
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='def', type='uint32'}
   },
   [11017] = {
      {name='num', type='uint32'}
   },
   [11019] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='partner_id', type='uint32'}
   },
   [11020] = {
      {name='partner_skins', type='array', fields={
          {name='id', type='uint32'},
          {name='end_time', type='uint32'}
      }}
   },
   [11025] = {
      {name='sort_type', type='uint8'},
      {name='num', type='uint32'},
      {name='buy_num', type='uint8'},
      {name='partners', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='skills', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_bid', type='uint32'}
          }},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='is_lock', type='array', fields={
              {name='lock_type', type='uint32'},
              {name='is_lock', type='uint8'}
          }},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint32'},
          {name='resonate_lev', type='uint32'},
          {name='resonate_break_lev', type='uint32'}
      }}
   },
   [11026] = {
      {name='partners', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'},
          {name='eqms', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'}
          }},
          {name='artifacts', type='array', fields={
              {name='artifact_pos', type='uint8'},
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='enchant', type='uint32'},
              {name='attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }}
      }}
   },
   [11030] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='partner_id', type='uint32'}
   },
   [11031] = {
      {name='partner_id', type='uint32'},
      {name='power', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='def', type='uint32'},
      {name='artifacts', type='array', fields={
          {name='artifact_pos', type='uint8'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }}
   },
   [11032] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11033] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='luck_item', type='uint8'}
   },
   [11034] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11035] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11036] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='flag', type='uint8'}
   },
   [11037] = {
      {name='lucky', type='uint32'}
   },
   [11038] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11040] = {
      {name='partners', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='max_star', type='uint8'}
      }},
      {name='all_star', type='uint32'},
      {name='lev', type='uint32'},
      {name='decompose_partners', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11041] = {
      {name='like', type='uint8'},
      {name='like_num', type='uint32'},
      {name='partner_comments', type='array', fields={
          {name='comment_id', type='uint32'},
          {name='name', type='string'},
          {name='msg', type='string'},
          {name='like_num', type='uint32'},
          {name='no_like_num', type='uint32'},
          {name='is_like', type='uint8'}
      }}
   },
   [11042] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11043] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11044] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'}
   },
   [11045] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='partner_id', type='uint32'}
   },
   [11046] = {
      {name='old_star', type='uint32'},
      {name='new_star', type='uint32'}
   },
   [11047] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='lev', type='uint32'}
   },
   [11048] = {
      {name='artifact_ref_count', type='array', fields={
          {name='type', type='uint8'},
          {name='current', type='uint32'},
          {name='limit', type='uint32'}
      }}
   },
   [11050] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='lev', type='uint32'},
      {name='fields', type='array', fields={
          {name='pos', type='uint32'},
          {name='partner_id', type='uint32'}
      }}
   },
   [11051] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11052] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='lev', type='uint32'}
   },
   [11053] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='pos', type='uint8'}
   },
   [11055] = {
   },
   [11056] = {
      {name='is_point', type='uint8'}
   },
   [11060] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11061] = {
      {name='partner_id', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_bid', type='uint32'}
      }},
      {name='break_lev', type='uint8'},
      {name='power', type='uint32'},
      {name='is_lock', type='array', fields={
          {name='lock_type', type='uint32'},
          {name='is_lock', type='uint8'}
      }},
      {name='use_skin', type='uint32'},
      {name='end_time', type='uint32'},
      {name='resonate_lev', type='uint32'},
      {name='resonate_break_lev', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='dam', type='uint32'},
      {name='res', type='uint32'},
      {name='cure', type='uint32'},
      {name='be_cure', type='uint32'},
      {name='tenacity', type='uint32'},
      {name='def', type='uint32'},
      {name='dam_p', type='uint32'},
      {name='dam_s', type='uint32'},
      {name='res_p', type='uint32'},
      {name='res_s', type='uint32'},
      {name='atk2', type='uint32'},
      {name='hp2', type='uint32'},
      {name='def2', type='uint32'},
      {name='speed2', type='uint32'},
      {name='eqms', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='type', type='uint32'}
      }},
      {name='artifacts', type='array', fields={
          {name='artifact_pos', type='uint8'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }},
      {name='dower_skill', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }},
      {name='ext_data', type='array', fields={
          {name='id', type='uint32'},
          {name='val', type='uint32'}
      }},
      {name='holy_eqm', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }}
      }},
      {name='r_rid', type='uint32'},
      {name='r_srvid', type='string'}
   },
   [11062] = {
      {name='partner_id', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_bid', type='uint32'}
      }},
      {name='break_lev', type='uint8'},
      {name='power', type='uint32'},
      {name='is_lock', type='array', fields={
          {name='lock_type', type='uint32'},
          {name='is_lock', type='uint8'}
      }},
      {name='use_skin', type='uint32'},
      {name='end_time', type='uint32'},
      {name='resonate_lev', type='uint32'},
      {name='resonate_break_lev', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='dam', type='uint32'},
      {name='res', type='uint32'},
      {name='cure', type='uint32'},
      {name='be_cure', type='uint32'},
      {name='tenacity', type='uint32'},
      {name='def', type='uint32'},
      {name='dam_p', type='uint32'},
      {name='dam_s', type='uint32'},
      {name='res_p', type='uint32'},
      {name='res_s', type='uint32'},
      {name='atk2', type='uint32'},
      {name='hp2', type='uint32'},
      {name='def2', type='uint32'},
      {name='speed2', type='uint32'},
      {name='eqms', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='type', type='uint32'}
      }},
      {name='artifacts', type='array', fields={
          {name='artifact_pos', type='uint8'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }},
      {name='dower_skill', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }},
      {name='ext_data', type='array', fields={
          {name='id', type='uint32'},
          {name='val', type='uint32'}
      }},
      {name='holy_eqm', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }}
      }},
      {name='r_rid', type='uint32'},
      {name='r_srvid', type='string'}
   },
   [11063] = {
      {name='partner_id', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='dam', type='uint32'},
      {name='res', type='uint32'},
      {name='cure', type='uint32'},
      {name='be_cure', type='uint32'},
      {name='tenacity', type='uint32'},
      {name='def', type='uint32'},
      {name='dam_p', type='uint32'},
      {name='dam_s', type='uint32'},
      {name='res_p', type='uint32'},
      {name='res_s', type='uint32'},
      {name='ext_data', type='array', fields={
          {name='id', type='uint32'},
          {name='val', type='uint32'}
      }}
   },
   [11065] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='is_partner', type='uint8'},
          {name='id', type='uint32'},
          {name='num', type='uint32'},
          {name='star', type='uint32'},
          {name='lev', type='uint32'}
      }},
      {name='partner_id', type='uint32'}
   },
   [11066] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='is_partner', type='uint8'},
          {name='id', type='uint32'},
          {name='num', type='uint32'},
          {name='star', type='uint32'},
          {name='lev', type='uint32'}
      }}
   },
   [11067] = {
      {name='partner_id', type='uint32'},
      {name='end_time', type='uint32'},
      {name='day_num', type='uint8'}
   },
   [11068] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [11070] = {
      {name='partner_bid', type='uint32'},
      {name='partner_score', type='array', fields={
          {name='id_2', type='uint8'},
          {name='val', type='uint32'}
      }},
      {name='stronger_partner_score', type='array', fields={
          {name='id_2', type='uint8'},
          {name='val', type='uint32'}
      }}
   },
   [11071] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11072] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [11073] = {
      {name='partners', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='skills', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_bid', type='uint32'}
          }},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='is_lock', type='array', fields={
              {name='lock_type', type='uint32'},
              {name='is_lock', type='uint8'}
          }},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint32'},
          {name='resonate_lev', type='uint32'},
          {name='resonate_break_lev', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'},
          {name='atk2', type='uint32'},
          {name='hp2', type='uint32'},
          {name='def2', type='uint32'},
          {name='speed2', type='uint32'},
          {name='eqms', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'}
          }},
          {name='artifacts', type='array', fields={
              {name='artifact_pos', type='uint8'},
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='enchant', type='uint32'},
              {name='attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }},
          {name='dower_skill', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_id', type='uint32'}
          }}
      }}
   },
   [11074] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11075] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [11076] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [11077] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='partner_bid', type='uint32'}
   },
   [11078] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [11079] = {
      {name='type', type='uint8'},
      {name='coin', type='uint32'},
      {name='list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint16'}
      }}
   },
   [11080] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11081] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11082] = {
      {name='logs', type='array', fields={
          {name='items', type='array', fields={
              {name='bid', type='uint32'},
              {name='num', type='uint16'}
          }},
          {name='time', type='uint32'},
          {name='coin', type='uint32'}
      }}
   },
   [11083] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='partner_id', type='uint32'},
      {name='item_id', type='uint32'}
   },
   [11085] = {
      {name='partner_id', type='uint32'},
      {name='old_star', type='uint32'},
      {name='new_star', type='uint32'}
   },
   [11086] = {
      {name='partner_id', type='uint32'},
      {name='power', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='dam', type='uint32'},
      {name='res', type='uint32'},
      {name='cure', type='uint32'},
      {name='be_cure', type='uint32'},
      {name='tenacity', type='uint32'},
      {name='def', type='uint32'},
      {name='dam_p', type='uint32'},
      {name='dam_s', type='uint32'},
      {name='res_p', type='uint32'},
      {name='res_s', type='uint32'}
   },
   [11087] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [11088] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [11089] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [11090] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11091] = {
      {name='partner_id', type='uint32'},
      {name='power', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='dam', type='uint32'},
      {name='res', type='uint32'},
      {name='cure', type='uint32'},
      {name='be_cure', type='uint32'},
      {name='tenacity', type='uint32'},
      {name='def', type='uint32'},
      {name='dam_p', type='uint32'},
      {name='dam_s', type='uint32'},
      {name='res_p', type='uint32'},
      {name='res_s', type='uint32'},
      {name='holy_eqm', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }}
   },
   [11092] = {
      {name='partner_ids', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='holy_eqm', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='main_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='holy_eqm_attr', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }}
      }}
   },
   [11093] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11094] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11095] = {
      {name='partner_bid', type='uint32'},
      {name='is_chips', type='uint8'},
      {name='init_star', type='uint8'},
      {name='status', type='uint8'}
   },
   [11096] = {
      {name='partner_id', type='uint32'},
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='dower_skill', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [11097] = {
      {name='partner_id', type='uint32'},
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='dower_skill', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [11098] = {
      {name='partner_id', type='uint32'},
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='dower_skill', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [11099] = {
      {name='partner_ids', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='dower_skill', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_id', type='uint32'}
          }}
      }}
   },
   [11100] = {
   },
   [11101] = {
      {name='drama_bid', type='uint32'}
   },
   [11102] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [11110] = {
      {name='id', type='uint8'},
      {name='act_list', type='array', fields={
          {name='id', type='uint16'},
          {name='act_type', type='uint8'},
          {name='base_id', type='uint32'},
          {name='map_bid', type='uint32'},
          {name='x', type='uint16'},
          {name='y', type='uint16'},
          {name='val', type='uint32'},
          {name='name', type='string'},
          {name='desc', type='string'}
      }}
   },
   [11111] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [11120] = {
      {name='id', type='uint32'},
      {name='n', type='uint32'}
   },
   [11121] = {
      {name='id', type='uint32'},
      {name='n', type='uint32'}
   },
   [11122] = {
   },
   [11123] = {
   },
   [11200] = {
      {name='id', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint8'}
      }},
      {name='formation_list', type='array', fields={
          {name='id', type='uint8'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [11201] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [11211] = {
      {name='type', type='uint8'},
      {name='formation_type', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [11212] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'}
   },
   [11213] = {
      {name='info', type='array', fields={
          {name='type', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'}
      }}
   },
   [11300] = {
      {name='star', type='array', fields={
          {name='set_id', type='uint32'},
          {name='add_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='set_skill_id', type='uint32'},
          {name='power', type='uint32'},
          {name='natals', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'},
              {name='enchant', type='uint32'},
              {name='break_count', type='uint32'},
              {name='star_lev', type='uint32'},
              {name='score', type='uint32'},
              {name='all_score', type='uint32'}
          }}
      }},
      {name='fetters', type='array', fields={
          {name='set_id', type='uint32'},
          {name='pos_id', type='uint32'},
          {name='partner_id', type='uint32'}
      }}
   },
   [11301] = {
      {name='set_id', type='uint32'},
      {name='add_attr', type='array', fields={
          {name='attr_id', type='uint32'},
          {name='attr_val', type='uint32'}
      }},
      {name='set_skill_id', type='uint32'},
      {name='power', type='uint32'},
      {name='natals', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='type', type='uint32'},
          {name='enchant', type='uint32'},
          {name='break_count', type='uint32'},
          {name='star_lev', type='uint32'},
          {name='score', type='uint32'},
          {name='all_score', type='uint32'}
      }}
   },
   [11302] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='old_set_id', type='uint32'},
      {name='fetter', type='array', fields={
          {name='set_id', type='uint32'},
          {name='pos_id', type='uint32'},
          {name='partner_id', type='uint32'}
      }}
   },
   [11303] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='old_set_id', type='uint32'},
      {name='fetter', type='array', fields={
          {name='set_id', type='uint32'},
          {name='pos_id', type='uint32'},
          {name='partner_id', type='uint32'}
      }}
   },
   [11304] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11305] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11306] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [11307] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='fetter', type='array', fields={
          {name='set_id', type='uint32'},
          {name='pos_id', type='uint32'},
          {name='partner_id', type='uint32'}
      }}
   },
   [11308] = {
      {name='star', type='array', fields={
          {name='set_id', type='uint32'},
          {name='add_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='set_skill_id', type='uint32'},
          {name='power', type='uint32'},
          {name='natals', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'},
              {name='enchant', type='uint32'},
              {name='break_count', type='uint32'},
              {name='star_lev', type='uint32'},
              {name='score', type='uint32'},
              {name='all_score', type='uint32'}
          }}
      }},
      {name='fetters', type='array', fields={
          {name='set_id', type='uint32'},
          {name='pos_id', type='uint32'},
          {name='partner_id', type='uint32'}
      }}
   },
   [11310] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='set_id', type='uint32'},
      {name='id', type='uint32'},
      {name='lev', type='uint32'}
   },
   [11311] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='set_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [11320] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='max_tower', type='uint32'},
      {name='count', type='uint32'},
      {name='buy_count', type='uint32'},
      {name='award_list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [11321] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='buy_count', type='uint32'}
   },
   [11322] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11323] = {
      {name='result', type='uint8'},
      {name='max_tower', type='uint32'},
      {name='tower', type='uint32'},
      {name='timer', type='uint32'},
      {name='count', type='uint32'},
      {name='first_award', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='award', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='replay_id', type='uint32'},
      {name='is_skip', type='uint8'}
   },
   [11324] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='buy_count', type='uint32'}
   },
   [11325] = {
      {name='tower_replay_data', type='array', fields={
          {name='type', type='uint8'},
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='time', type='uint32'},
          {name='replay_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='m_replay_id', type='uint32'},
      {name='my_time', type='uint32'}
   },
   [11326] = {
      {name='tower', type='uint32'}
   },
   [11327] = {
      {name='rank_lists', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='rank', type='uint32'},
          {name='tower', type='uint32'}
      }}
   },
   [11328] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [11329] = {
      {name='award_list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [11330] = {
      {name='quality', type='uint32'},
      {name='luck', type='uint32'},
      {name='end_count', type='uint32'},
      {name='ref_count', type='uint32'},
      {name='day_gold_count', type='uint32'},
      {name='flag', type='uint8'}
   },
   [11331] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='end_count', type='uint32'},
      {name='quality', type='uint32'},
      {name='day_gold_count', type='uint32'},
      {name='flag', type='uint8'},
      {name='award', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='award2', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [11332] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='luck', type='uint32'},
      {name='ref_count', type='uint32'}
   },
   [11333] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [12700] = {
      {name='say_frame_bid', type='uint32'},
      {name='say_frame', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [12701] = {
      {name='base_id', type='uint32'}
   },
   [12702] = {
      {name='say_frame', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [12703] = {
      {name='say_frame', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [12704] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [12720] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [12721] = {
      {name='flag', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='career', type='uint16'},
      {name='face_id', type='uint32'},
      {name='len', type='uint8'},
      {name='msg', type='string'},
      {name='sex', type='uint8'},
      {name='vip_lev', type='uint8'},
      {name='capacity', type='uint8'},
      {name='head_bid', type='uint32'},
      {name='bubble_bid', type='uint32'},
      {name='tick', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [12722] = {
      {name='offline_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='career', type='uint16'},
          {name='face_id', type='uint32'},
          {name='sex', type='uint8'},
          {name='vip_lev', type='uint8'},
          {name='capacity', type='uint8'},
          {name='head_bid', type='uint32'},
          {name='chat_bubble', type='uint32'},
          {name='msg_list', type='array', fields={
              {name='len', type='uint8'},
              {name='msg', type='string'},
              {name='tick', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [12723] = {
   },
   [12725] = {
      {name='flag', type='uint8'},
      {name='srv_id', type='string'},
      {name='voice_id', type='uint32'},
      {name='msg', type='string'}
   },
   [12726] = {
      {name='srv_id', type='string'},
      {name='voice_id', type='uint32'},
      {name='time', type='uint8'},
      {name='voice', type='byte'},
      {name='type', type='uint8'}
   },
   [12729] = {
   },
   [12730] = {
   },
   [12731] = {
   },
   [12732] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [12733] = {
      {name='type', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='msg', type='string'},
          {name='time', type='uint32'}
      }}
   },
   [12741] = {
      {name='msg', type='string'}
   },
   [12742] = {
      {name='asset_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='is_bind', type='uint8'},
          {name='num', type='uint32'},
          {name='id', type='uint32'},
          {name='move_to', type='uint8'}
      }},
      {name='source', type='uint32'}
   },
   [12743] = {
      {name='msg', type='string'}
   },
   [12744] = {
      {name='type', type='uint8'},
      {name='msg', type='string'}
   },
   [12745] = {
      {name='bid', type='uint32'},
      {name='need_num', type='uint32'},
      {name='num', type='uint32'}
   },
   [12761] = {
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='lev', type='uint8'},
          {name='sex', type='uint8'},
          {name='career', type='uint16'},
          {name='vip_lev', type='uint8'},
          {name='is_show_vip', type='uint8'},
          {name='province', type='string'},
          {name='city', type='string'},
          {name='capacity', type='uint8'},
          {name='head_bid', type='uint32'},
          {name='bubble_bid', type='uint32'},
          {name='ext_list', type='array', fields={
              {name='type', type='uint8'},
              {name='val', type='uint32'}
          }},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='g_name', type='string'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='channel', type='uint16'},
      {name='len', type='uint8'},
      {name='msg', type='string'},
      {name='tick', type='uint32'}
   },
   [12762] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [12763] = {
      {name='channel', type='uint16'},
      {name='id', type='string'},
      {name='msg', type='string'}
   },
   [12764] = {
   },
   [12766] = {
      {name='channel', type='uint16'},
      {name='msg_list', type='array', fields={
          {name='role_list', type='array', fields={
              {name='rid', type='uint32'},
              {name='srv_id', type='string'},
              {name='name', type='string'},
              {name='face_id', type='uint32'},
              {name='lev', type='uint8'},
              {name='sex', type='uint8'},
              {name='career', type='uint16'},
              {name='vip_lev', type='uint8'},
              {name='is_show_vip', type='uint8'},
              {name='province', type='string'},
              {name='city', type='string'},
              {name='capacity', type='uint8'},
              {name='head_bid', type='uint32'},
              {name='chat_bubble', type='uint32'},
              {name='ext_list', type='array', fields={
                  {name='type', type='uint8'},
                  {name='val', type='uint32'}
              }},
              {name='gid', type='uint32'},
              {name='gsrv_id', type='string'},
              {name='g_name', type='string'},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }},
          {name='channel', type='uint16'},
          {name='len', type='uint8'},
          {name='msg', type='string'},
          {name='tick', type='uint32'}
      }}
   },
   [12767] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='channel', type='uint16'},
      {name='msg', type='string'}
   },
   [12768] = {
   },
   [12770] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [12771] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='history', type='array', fields={
          {name='id', type='uint8'},
          {name='channel', type='uint16'},
          {name='msg', type='string'}
      }}
   },
   [12772] = {
      {name='msg', type='string'},
      {name='end_time', type='uint32'}
   },
   [12799] = {
      {name='msg', type='string'}
   },
   [12900] = {
      {name='is_cluster', type='uint8'},
      {name='type', type='uint16'},
      {name='start', type='uint8'},
      {name='num', type='uint8'},
      {name='len', type='uint8'},
      {name='time', type='uint32'},
      {name='my_idx', type='uint16'},
      {name='lev', type='uint8'},
      {name='face_id', type='uint16'},
      {name='avatar_bid', type='uint16'},
      {name='name', type='string'},
      {name='my_val1', type='uint32'},
      {name='my_val2', type='uint32'},
      {name='my_val3', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='guild_name', type='string'},
          {name='lev', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'},
          {name='val3', type='uint32'},
          {name='idx', type='uint8'},
          {name='desc', type='string'},
          {name='look_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [12901] = {
      {name='is_cluster', type='uint8'},
      {name='type', type='uint16'},
      {name='time', type='uint32'}
   },
   [12902] = {
      {name='is_cluster', type='uint8'},
      {name='rank_list', type='array', fields={
          {name='type', type='uint16'},
          {name='name', type='string'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='guild_name', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'},
          {name='val3', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [12903] = {
      {name='start', type='uint8'},
      {name='num', type='uint8'},
      {name='len', type='uint8'},
      {name='time', type='uint32'},
      {name='my_idx', type='uint16'},
      {name='gname', type='string'},
      {name='leader_name', type='string'},
      {name='glev', type='uint8'},
      {name='power', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='members_num', type='uint8'},
          {name='members_max', type='uint8'},
          {name='leader_name', type='string'},
          {name='power', type='uint32'},
          {name='idx', type='uint8'},
          {name='leader_rid', type='uint32'},
          {name='leader_srvid', type='string'},
          {name='leader_face', type='uint32'},
          {name='leader_lev', type='uint8'},
          {name='leader_avatar_bid', type='uint32'},
          {name='leader_look_id', type='uint32'},
          {name='leader_face_update_time', type='uint32'},
          {name='leader_face_file', type='string'}
      }}
   },
   [12904] = {
      {name='start', type='uint8'},
      {name='num', type='uint8'},
      {name='len', type='uint8'},
      {name='time', type='uint32'},
      {name='my_idx', type='uint16'},
      {name='lev', type='uint8'},
      {name='face_id', type='uint16'},
      {name='avatar_bid', type='uint32'},
      {name='name', type='string'},
      {name='pid', type='uint16'},
      {name='pbid', type='uint16'},
      {name='plev', type='uint8'},
      {name='pquality', type='uint8'},
      {name='pstar', type='uint8'},
      {name='power', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='power', type='uint32'},
          {name='idx', type='uint8'},
          {name='pid', type='uint16'},
          {name='pbid', type='uint16'},
          {name='plev', type='uint8'},
          {name='pquality', type='uint8'},
          {name='pstar', type='uint8'},
          {name='look_id', type='uint32'}
      }}
   },
   [13000] = {
      {name='mode', type='uint8'},
      {name='chapter_id', type='uint8'},
      {name='dun_id', type='uint32'},
      {name='status', type='uint8'},
      {name='is_first', type='uint8'},
      {name='cool_time', type='uint32'},
      {name='max_dun_id', type='uint32'},
      {name='auto_num', type='uint8'},
      {name='auto_num_max', type='uint8'},
      {name='mode_list', type='array', fields={
          {name='mode', type='uint8'},
          {name='chapter_list', type='array', fields={
              {name='chapter_id', type='uint8'},
              {name='status', type='uint8'},
              {name='dun_list', type='array', fields={
                  {name='dun_id', type='uint32'},
                  {name='status', type='uint8'},
                  {name='cool_time', type='uint32'},
                  {name='auto_num', type='uint8'}
              }}
          }}
      }}
   },
   [13001] = {
      {name='mode', type='uint8'},
      {name='chapter_id', type='uint8'},
      {name='dun_id', type='uint32'},
      {name='status', type='uint8'},
      {name='is_first', type='uint8'},
      {name='cool_time', type='uint32'},
      {name='max_dun_id', type='uint32'}
   },
   [13002] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13003] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13004] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13005] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='dun_id', type='uint32'},
      {name='num', type='uint16'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [13006] = {
      {name='fast_combat_num', type='uint8'},
      {name='fast_combat_max', type='uint8'},
      {name='auto_num', type='uint8'},
      {name='auto_num_max', type='uint8'},
      {name='is_auto_combat', type='uint8'},
      {name='fast_combat_add_time', type='uint16'},
      {name='fast_combat_w_num', type='uint8'},
      {name='fast_combat_p_num', type='uint8'},
      {name='fast_combat_free_num', type='uint8'},
      {name='is_holiday', type='uint8'}
   },
   [13007] = {
      {name='type', type='uint8'},
      {name='dun_id', type='uint32'},
      {name='time', type='uint32'},
      {name='old_lev', type='uint8'},
      {name='new_lev', type='uint8'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='auto_start_dun_id', type='uint32'},
      {name='auto_end_dun_id', type='uint32'},
      {name='fast_add_time1', type='uint32'},
      {name='fast_add_time2', type='uint32'},
      {name='old_exp', type='uint32'},
      {name='new_exp', type='uint32'},
      {name='vip_buff', type='uint32'},
      {name='honor_buff', type='uint32'}
   },
   [13008] = {
      {name='list', type='array', fields={
          {name='id', type='uint8'}
      }}
   },
   [13009] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [13010] = {
      {name='dun_id', type='uint32'},
      {name='chapter_id', type='uint8'}
   },
   [13011] = {
      {name='buff_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='end_time', type='uint32'}
      }}
   },
   [13012] = {
      {name='chapter_list', type='array', fields={
          {name='chapter_id', type='uint32'},
          {name='award_list', type='array', fields={
              {name='award_id', type='uint32'},
              {name='status', type='uint32'}
          }}
      }}
   },
   [13013] = {
      {name='chapter_list', type='array', fields={
          {name='chapter_id', type='uint32'},
          {name='award_list', type='array', fields={
              {name='award_id', type='uint32'},
              {name='status', type='uint32'}
          }}
      }}
   },
   [13014] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='chapter_id', type='uint32'},
      {name='award_id', type='uint32'},
      {name='status', type='uint32'}
   },
   [13015] = {
      {name='dungeon_replay_log', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='time', type='uint32'},
          {name='repaly_id', type='uint32'},
          {name='type', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13016] = {
      {name='result', type='uint8'},
      {name='item_rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='is_bind', type='uint8'},
          {name='num', type='uint32'},
          {name='id', type='uint32'}
      }},
      {name='combat_type', type='uint16'},
      {name='partner_bid', type='uint32'},
      {name='partner_hurt', type='uint32'},
      {name='partner_total_hurt', type='uint32'},
      {name='lev', type='uint8'},
      {name='exp', type='uint32'},
      {name='new_lev', type='uint8'},
      {name='new_exp', type='uint32'},
      {name='auto_num', type='uint16'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='use_skin', type='uint32'}
   },
   [13017] = {
      {name='hook_time', type='uint32'},
      {name='list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [13018] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13019] = {
   },
   [13020] = {
      {name='val', type='uint32'}
   },
   [13030] = {
      {name='list', type='array', fields={
          {name='type', type='uint32'},
          {name='day_num', type='uint8'}
      }},
      {name='pass_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [13031] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13032] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [13300] = {
      {name='present_count', type='uint16'},
      {name='draw_count', type='uint16'},
      {name='draw_all', type='uint16'},
      {name='friend_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='sex', type='uint8'},
          {name='career', type='uint8'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='intimacy', type='uint32'},
          {name='login_time', type='uint32'},
          {name='login_out_time', type='uint32'},
          {name='is_online', type='uint8'},
          {name='is_cross', type='uint8'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='gname', type='string'},
          {name='main_partner_id', type='uint32'},
          {name='partner_bid', type='uint32'},
          {name='partner_lev', type='uint16'},
          {name='partner_star', type='uint8'},
          {name='is_awake', type='uint8'},
          {name='is_used', type='uint8'},
          {name='is_present', type='uint8'},
          {name='is_draw', type='uint8'},
          {name='avatar_bid', type='uint32'},
          {name='dun_id', type='uint32'},
          {name='is_home', type='uint8'},
          {name='soft', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13301] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='login_time', type='uint32'},
      {name='is_online', type='uint8'},
      {name='login_out_time', type='uint32'}
   },
   [13302] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='sex', type='uint8'},
      {name='career', type='uint8'},
      {name='face_id', type='uint32'},
      {name='power', type='uint32'},
      {name='intimacy', type='uint32'},
      {name='login_time', type='uint32'},
      {name='login_out_time', type='uint32'},
      {name='is_online', type='uint8'},
      {name='is_cross', type='uint8'},
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='gname', type='string'},
      {name='main_partner_id', type='uint32'},
      {name='partner_bid', type='uint32'},
      {name='partner_lev', type='uint16'},
      {name='partner_star', type='uint8'},
      {name='is_awake', type='uint8'},
      {name='is_used', type='uint8'},
      {name='is_present', type='uint8'},
      {name='is_draw', type='uint8'},
      {name='avatar_bid', type='uint32'},
      {name='dun_id', type='uint32'},
      {name='is_home', type='uint8'},
      {name='soft', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [13303] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13304] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='sex', type='uint8'},
      {name='career', type='uint8'},
      {name='lev', type='uint8'},
      {name='avatar_bid', type='uint32'}
   },
   [13305] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13306] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13307] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13308] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13309] = {
      {name='role_ids', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [13310] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='sex', type='uint8'},
      {name='career', type='uint8'},
      {name='face_id', type='uint32'},
      {name='power', type='uint32'},
      {name='intimacy', type='uint32'},
      {name='login_time', type='uint32'},
      {name='login_out_time', type='uint32'},
      {name='is_online', type='uint8'},
      {name='is_cross', type='uint8'},
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='gname', type='string'},
      {name='main_partner_id', type='uint32'},
      {name='partner_bid', type='uint32'},
      {name='partner_lev', type='uint16'},
      {name='partner_star', type='uint8'},
      {name='is_awake', type='uint8'},
      {name='is_used', type='uint8'},
      {name='is_present', type='uint8'},
      {name='is_draw', type='uint8'},
      {name='avatar_bid', type='uint32'},
      {name='dun_id', type='uint32'},
      {name='is_home', type='uint8'},
      {name='soft', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [13311] = {
      {name='friend_req_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='sex', type='uint8'},
          {name='career', type='uint8'},
          {name='lev', type='uint8'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13312] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13314] = {
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='sex', type='uint8'},
          {name='career', type='uint8'},
          {name='lev', type='uint8'},
          {name='power', type='uint32'},
          {name='face_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13315] = {
      {name='code', type='uint8'}
   },
   [13316] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='present_count', type='uint16'},
      {name='draw_count', type='uint16'},
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'},
      {name='is_present', type='uint8'},
      {name='is_draw', type='uint8'}
   },
   [13317] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'},
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='is_present', type='uint8'},
          {name='is_draw', type='uint8'}
      }}
   },
   [13320] = {
      {name='recommend_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='sex', type='uint8'},
          {name='career', type='uint8'},
          {name='lev', type='uint8'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13330] = {
      {name='black_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='sex', type='uint8'},
          {name='career', type='uint8'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='login_out_time', type='uint32'},
          {name='is_online', type='uint8'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='gname', type='string'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13331] = {
      {name='type', type='uint8'},
      {name='black_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='sex', type='uint8'},
          {name='career', type='uint8'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='login_time', type='uint32'},
          {name='is_online', type='uint8'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='gname', type='string'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13332] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13333] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [13334] = {
      {name='role_ids', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [13401] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'},
      {name='is_half', type='uint8'},
      {name='item_list', type='array', fields={
          {name='item_id', type='uint32'},
          {name='ext', type='array', fields={
              {name='key', type='uint8'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [13402] = {
      {name='code', type='uint8'},
      {name='type', type='uint8'},
      {name='eid', type='uint32'},
      {name='is_half', type='uint8'},
      {name='ext', type='array', fields={
          {name='key', type='uint8'},
          {name='val', type='uint32'}
      }},
      {name='msg', type='string'}
   },
   [13403] = {
      {name='type', type='uint32'},
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='free_count', type='uint32'},
      {name='num', type='uint32'},
      {name='refresh_time', type='uint32'},
      {name='item_list', type='array', fields={
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'},
          {name='order', type='uint32'},
          {name='price', type='uint32'},
          {name='type', type='uint8'},
          {name='pay_type', type='uint32'},
          {name='has_buy', type='uint32'},
          {name='limit_count', type='uint32'},
          {name='limit_day', type='uint32'},
          {name='limit_week', type='uint32'},
          {name='limit_month', type='uint32'},
          {name='discount_type', type='uint32'},
          {name='discount', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_type', type='uint8'},
              {name='val', type='uint32'}
          }},
          {name='pay_type2', type='uint32'},
          {name='price2', type='uint32'},
          {name='score', type='uint32'},
          {name='item_desc', type='string'}
      }}
   },
   [13404] = {
   },
   [13405] = {
      {name='type', type='uint32'},
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='free_count', type='uint32'},
      {name='num', type='uint32'},
      {name='refresh_time', type='uint32'},
      {name='item_list', type='array', fields={
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'},
          {name='order', type='uint32'},
          {name='price', type='uint32'},
          {name='type', type='uint8'},
          {name='pay_type', type='uint32'},
          {name='has_buy', type='uint32'},
          {name='limit_count', type='uint32'},
          {name='limit_day', type='uint32'},
          {name='limit_week', type='uint32'},
          {name='limit_month', type='uint32'},
          {name='discount_type', type='uint32'},
          {name='discount', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_type', type='uint8'},
              {name='val', type='uint32'}
          }},
          {name='pay_type2', type='uint32'},
          {name='price2', type='uint32'},
          {name='score', type='uint32'},
          {name='item_desc', type='string'}
      }}
   },
   [13407] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='order', type='uint32'},
      {name='num', type='uint32'},
      {name='type', type='uint32'}
   },
   [13408] = {
      {name='code', type='uint8'}
   },
   [13409] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='item_list', type='array', fields={
          {name='pos', type='uint32'},
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'},
          {name='price', type='uint32'},
          {name='status', type='uint32'}
      }}
   },
   [13410] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='item_list', type='array', fields={
          {name='pos', type='uint32'},
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'},
          {name='price', type='uint32'},
          {name='status', type='uint32'}
      }}
   },
   [13411] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='item_list', type='array', fields={
          {name='pos', type='uint32'},
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'},
          {name='price', type='uint32'},
          {name='status', type='uint32'}
      }}
   },
   [13412] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint32'},
      {name='day', type='uint32'},
      {name='item_list', type='array', fields={
          {name='item_id', type='uint32'},
          {name='status', type='uint32'}
      }}
   },
   [13413] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint32'},
      {name='day', type='uint32'},
      {name='item_list', type='array', fields={
          {name='item_id', type='uint32'},
          {name='status', type='uint32'}
      }}
   },
   [13414] = {
      {name='code', type='uint8'}
   },
   [13415] = {
      {name='type', type='uint32'},
      {name='count', type='uint16'},
      {name='max_count', type='uint16'},
      {name='free_count', type='uint8'},
      {name='max_free_count', type='uint8'},
      {name='item_list', type='array', fields={
          {name='order', type='uint8'},
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'},
          {name='price', type='uint32'},
          {name='type', type='uint8'},
          {name='pay_type', type='uint8'},
          {name='buycount', type='uint32'},
          {name='discount_type', type='uint32'},
          {name='discount', type='uint32'}
      }}
   },
   [13416] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='order', type='uint32'}
   },
   [13417] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13418] = {
   },
   [13419] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13420] = {
      {name='type', type='uint32'},
      {name='count', type='uint32'},
      {name='free_count', type='uint32'},
      {name='refresh_time', type='uint32'}
   },
   [13500] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13501] = {
      {name='page', type='uint16'},
      {name='flag', type='uint8'},
      {name='num', type='uint16'},
      {name='page_total', type='uint16'},
      {name='all_count', type='uint16'},
      {name='name', type='string'},
      {name='guilds', type='array', fields={
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='members_num', type='uint8'},
          {name='members_max', type='uint8'},
          {name='leader_name', type='string'},
          {name='apply_type', type='uint8'},
          {name='apply_lev', type='uint8'},
          {name='apply_power', type='uint32'},
          {name='is_apply', type='uint8'}
      }}
   },
   [13503] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='is_apply', type='uint8'}
   },
   [13505] = {
      {name='type', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13507] = {
      {name='page', type='uint8'},
      {name='page_total', type='uint8'},
      {name='num', type='uint8'},
      {name='guids', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='vip_lev', type='uint8'},
          {name='is_online', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13513] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13514] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13516] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13518] = {
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='members_num', type='uint8'},
      {name='members_max', type='uint8'},
      {name='leader_name', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='sign', type='string'},
      {name='exp', type='uint32'},
      {name='day_exp', type='uint32'},
      {name='apply_type', type='uint8'},
      {name='apply_lev', type='uint8'},
      {name='recruit_num', type='uint8'},
      {name='vitality', type='uint32'},
      {name='apply_power', type='uint32'},
      {name='rank_idx', type='int16'}
   },
   [13519] = {
      {name='members', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='face', type='uint32'},
          {name='post', type='uint8'},
          {name='online', type='uint8'},
          {name='vip_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='join_time', type='uint32'},
          {name='login_time', type='uint32'},
          {name='donate', type='uint32'},
          {name='day_donate', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='sex', type='uint8'},
          {name='active_lev', type='uint8'},
          {name='day_dun_time', type='uint8'},
          {name='day_war_time', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13520] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='position', type='uint8'},
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13521] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13522] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13523] = {
      {name='donate_list', type='array', fields={
          {name='type', type='uint8'},
          {name='num', type='uint8'}
      }},
      {name='boxes', type='array', fields={
          {name='box_id', type='uint8'}
      }},
      {name='donate_exp', type='uint32'},
      {name='day_send_num', type='uint8'},
      {name='day_recv_num', type='uint8'}
   },
   [13524] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13534] = {
      {name='type', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='type', type='uint8'},
          {name='name', type='string'},
          {name='post', type='uint32'},
          {name='num', type='uint8'},
          {name='max_num', type='uint8'},
          {name='max_val', type='uint32'},
          {name='time', type='uint32'},
          {name='flag', type='uint8'},
          {name='msg_id', type='uint8'}
      }}
   },
   [13535] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='day_send_num', type='uint8'}
   },
   [13536] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='type', type='uint8'},
      {name='val', type='uint32'},
      {name='day_recv_num', type='uint8'}
   },
   [13540] = {
      {name='id', type='uint32'},
      {name='type', type='uint8'},
      {name='name', type='string'},
      {name='face_id', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='avatar_bid', type='uint32'},
      {name='post', type='uint32'},
      {name='val', type='uint32'},
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='post', type='uint32'},
          {name='val', type='uint32'},
          {name='time', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13541] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13542] = {
      {name='type', type='uint8'},
      {name='members', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='face', type='uint32'},
          {name='post', type='uint8'},
          {name='online', type='uint8'},
          {name='vip_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='join_time', type='uint32'},
          {name='login_time', type='uint32'},
          {name='donate', type='uint32'},
          {name='day_donate', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='sex', type='uint8'},
          {name='active_lev', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13545] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='price', type='uint32'},
          {name='num', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [13546] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [13558] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13565] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13568] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13573] = {
      {name='code', type='uint8'}
   },
   [13574] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='box_id', type='uint8'}
   },
   [13575] = {
      {name='donate_exp', type='uint32'}
   },
   [13576] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13577] = {
      {name='guild_log_info_list', type='array', fields={
          {name='id', type='uint8'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='type', type='uint8'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='role_name', type='string'},
          {name='msg', type='string'}
      }}
   },
   [13578] = {
      {name='guild_log_info_list', type='array', fields={
          {name='id', type='uint8'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='type', type='uint8'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='role_name', type='string'},
          {name='msg', type='string'}
      }}
   },
   [13579] = {
      {name='msg', type='string'}
   },
   [13580] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13601] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='period', type='uint8'},
      {name='charge', type='uint32'},
      {name='cur_day', type='uint32'},
      {name='num', type='uint32'},
      {name='end_time', type='uint32'},
      {name='welfare_list', type='array', fields={
          {name='day', type='uint32'},
          {name='goal_id', type='uint32'},
          {name='status', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }},
      {name='grow_list', type='array', fields={
          {name='day', type='uint32'},
          {name='goal_id', type='uint32'},
          {name='condition', type='uint32'},
          {name='lev', type='uint32'},
          {name='status', type='uint8'},
          {name='target_type', type='uint8'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }},
      {name='price_list', type='array', fields={
          {name='day', type='uint32'},
          {name='status', type='uint8'}
      }},
      {name='finish_list', type='array', fields={
          {name='goal_id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [13602] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'},
      {name='day_type', type='uint32'},
      {name='id', type='uint32'},
      {name='item', type='uint32'},
      {name='status', type='uint8'},
      {name='num', type='uint32'}
   },
   [13603] = {
      {name='grow_list', type='array', fields={
          {name='day', type='uint32'},
          {name='goal_id', type='uint32'},
          {name='condition', type='uint32'},
          {name='lev', type='uint32'},
          {name='status', type='uint8'},
          {name='target_type', type='uint8'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }}
   },
   [13604] = {
      {name='period', type='uint8'},
      {name='cur_day', type='uint32'},
      {name='end_time', type='uint32'},
      {name='lev', type='uint32'},
      {name='exp', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [13605] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [13606] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [13607] = {
      {name='lev', type='uint32'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [13608] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [13609] = {
      {name='lev', type='uint32'},
      {name='exp', type='uint32'}
   },
   [14100] = {
      {name='day', type='uint8'},
      {name='status', type='uint8'}
   },
   [14101] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='day', type='uint8'},
      {name='status', type='uint8'}
   },
   [14102] = {
      {name='attr_list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [14103] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='status', type='uint8'}
   },
   [14104] = {
   },
   [16400] = {
      {name='feat_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }}
   },
   [16401] = {
      {name='feat_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }}
   },
   [16402] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [16601] = {
      {name='holiday_list', type='array', fields={
          {name='camp_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='title', type='string'},
          {name='title2', type='string'},
          {name='ico', type='string'},
          {name='type_ico', type='uint8'},
          {name='top_banner', type='string'},
          {name='rule_str', type='string'},
          {name='time_str', type='string'},
          {name='bottom_alert', type='string'},
          {name='aim_title', type='string'},
          {name='panel_type', type='uint8'},
          {name='channel_ban', type='string'},
          {name='sort_val', type='uint8'},
          {name='reward_title', type='string'},
          {name='remain_sec', type='uint32'},
          {name='cli_type', type='uint32'},
          {name='cli_type_name', type='string'}
      }}
   },
   [16602] = {
      {name='holiday_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='can_get_num', type='uint8'}
      }}
   },
   [16603] = {
      {name='bid', type='uint32'},
      {name='cli_type', type='uint32'},
      {name='remain_sec', type='uint32'},
      {name='finish', type='uint32'},
      {name='aim_list', type='array', fields={
          {name='aim', type='uint32'},
          {name='aim_str', type='string'},
          {name='status', type='uint8'},
          {name='item_list', type='array', fields={
              {name='bid', type='uint32'},
              {name='num', type='uint32'}
          }},
          {name='aim_args', type='array', fields={
              {name='aim_args_key', type='uint8'},
              {name='aim_args_val', type='uint32'},
              {name='aim_args_str', type='string'}
          }}
      }},
      {name='item_effect_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='effect_1', type='uint8'},
          {name='effect_2', type='uint8'}
      }},
      {name='args', type='array', fields={
          {name='args_key', type='uint8'},
          {name='args_val', type='uint32'},
          {name='args_str', type='string'}
      }},
      {name='client_reward', type='string'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='sex', type='uint8'},
          {name='career', type='uint8'},
          {name='lev', type='uint8'},
          {name='val', type='uint32'},
          {name='rank_args', type='array', fields={
              {name='rank_args_key', type='uint8'},
              {name='rank_args_val', type='uint32'}
          }}
      }}
   },
   [16604] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16605] = {
      {name='status', type='array', fields={
          {name='bid', type='uint32'},
          {name='code', type='uint8'},
          {name='end_time', type='uint32'}
      }}
   },
   [16606] = {
      {name='bid', type='uint32'},
      {name='can_get_num', type='uint8'}
   },
   [16607] = {
      {name='type', type='uint8'}
   },
   [16610] = {
      {name='bid', type='uint32'},
      {name='aim', type='uint32'},
      {name='item_bid', type='uint32'}
   },
   [16620] = {
      {name='holiday_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='cli_type', type='uint32'},
          {name='remain_sec', type='uint32'},
          {name='finish', type='uint32'},
          {name='aim_list', type='array', fields={
              {name='aim', type='uint32'},
              {name='aim_str', type='string'},
              {name='status', type='uint8'},
              {name='item_list', type='array', fields={
                  {name='bid', type='uint32'},
                  {name='num', type='uint32'}
              }},
              {name='aim_args', type='array', fields={
                  {name='aim_args_key', type='uint8'},
                  {name='aim_args_val', type='uint32'},
                  {name='aim_args_str', type='string'}
              }}
          }},
          {name='item_effect_list', type='array', fields={
              {name='bid', type='uint32'},
              {name='effect_1', type='uint8'},
              {name='effect_2', type='uint8'}
          }},
          {name='args', type='array', fields={
              {name='args_key', type='uint8'},
              {name='args_val', type='uint32'},
              {name='args_str', type='string'}
          }},
          {name='client_reward', type='string'},
          {name='rank_list', type='array', fields={
              {name='rid', type='uint32'},
              {name='srv_id', type='string'},
              {name='name', type='string'},
              {name='sex', type='uint8'},
              {name='career', type='uint8'},
              {name='lev', type='uint8'},
              {name='val', type='uint32'},
              {name='rank_args', type='array', fields={
                  {name='rank_args_key', type='uint8'},
                  {name='rank_args_val', type='uint32'}
              }}
          }}
      }}
   },
   [16630] = {
      {name='code', type='uint8'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16631] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16633] = {
      {name='code', type='uint8'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16634] = {
   },
   [16635] = {
      {name='code', type='uint8'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16636] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16637] = {
      {name='dial_data', type='array', fields={
          {name='type', type='uint32'},
          {name='count', type='uint32'},
          {name='lucky', type='uint32'},
          {name='frist_type', type='uint32'},
          {name='lucky_award', type='array', fields={
              {name='lucky', type='uint32'}
          }},
          {name='end_time', type='uint32'},
          {name='rand_lists', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='status', type='uint8'}
          }},
          {name='log_list', type='array', fields={
              {name='role_name', type='string'},
              {name='bid', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [16638] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='frist_awards', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='awards1', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='awards2', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='awards3', type='array', fields={
          {name='pos', type='uint8'}
      }}
   },
   [16639] = {
      {name='type', type='uint32'},
      {name='count', type='uint32'},
      {name='lucky', type='uint32'},
      {name='frist_type', type='uint32'},
      {name='lucky_award', type='array', fields={
          {name='lucky', type='uint32'}
      }},
      {name='end_time', type='uint32'},
      {name='rand_lists', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [16640] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint32'}
   },
   [16641] = {
      {name='type', type='uint32'},
      {name='log_list', type='array', fields={
          {name='role_name', type='string'},
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16642] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint32'}
   },
   [16643] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='frist_awards', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='awards1', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='awards2', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='awards3', type='array', fields={
          {name='pos', type='uint8'}
      }}
   },
   [16650] = {
      {name='rank', type='uint32'},
      {name='rank_award', type='array', fields={
          {name='rank1', type='uint32'},
          {name='rank2', type='uint32'},
          {name='award', type='array', fields={
              {name='bid', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [16651] = {
      {name='period', type='uint8'},
      {name='is_buy', type='uint8'},
      {name='end_time', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'}
      }}
   },
   [16652] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16653] = {
      {name='is_buy', type='uint8'},
      {name='end_time', type='uint32'},
      {name='charge_id', type='uint32'},
      {name='award_list', type='array', fields={
          {name='id', type='uint32'},
          {name='acv_id', type='uint32'},
          {name='finish', type='uint8'},
          {name='award_time', type='uint32'},
          {name='award', type='array', fields={
              {name='bid', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [16654] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16660] = {
      {name='holiday_exchanges', type='array', fields={
          {name='bid', type='uint32'},
          {name='end_time', type='uint32'},
          {name='exchange_name', type='string'},
          {name='need_id', type='uint32'},
          {name='exchange_list', type='array', fields={
              {name='aim', type='uint32'},
              {name='aim_str', type='string'},
              {name='buy_count', type='uint32'},
              {name='limit_buy', type='uint32'},
              {name='lable', type='uint32'},
              {name='expend_id', type='uint32'},
              {name='expend_num', type='uint32'},
              {name='item_list', type='array', fields={
                  {name='bid', type='uint32'},
                  {name='num', type='uint32'}
              }},
              {name='aim_args', type='array', fields={
                  {name='aim_args_key', type='uint8'},
                  {name='aim_args_val', type='uint32'},
                  {name='aim_args_str', type='string'}
              }}
          }}
      }}
   },
   [16661] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='bid', type='uint32'},
      {name='aim', type='uint32'},
      {name='buy_count', type='uint32'}
   },
   [16665] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16666] = {
   },
   [16670] = {
      {name='num', type='uint32'},
      {name='gold', type='uint32'},
      {name='is_free', type='uint8'},
      {name='holiday_lev', type='uint32'},
      {name='award_list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint32'}
      }}
   },
   [16671] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'},
      {name='flag', type='uint8'}
   },
   [16672] = {
      {name='count', type='uint8'},
      {name='awards2', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16673] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [16674] = {
      {name='type', type='uint8'},
      {name='log_list', type='array', fields={
          {name='role_name', type='string'},
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16675] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [16676] = {
      {name='gold', type='uint32'}
   },
   [16680] = {
      {name='lucky', type='uint32'},
      {name='free_num', type='uint8'},
      {name='endtime', type='uint32'},
      {name='egg_status', type='array', fields={
          {name='pos', type='uint8'},
          {name='type', type='uint8'},
          {name='status', type='uint8'},
          {name='show_reward', type='array', fields={
              {name='item_id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [16681] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16682] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16683] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16684] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16685] = {
      {name='type', type='uint8'},
      {name='log_list', type='array', fields={
          {name='role_name', type='string'},
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [16686] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16687] = {
      {name='bid', type='uint32'},
      {name='code', type='uint8'}
   },
   [16688] = {
      {name='buy_info', type='array', fields={
          {name='id', type='uint8'},
          {name='day_num', type='uint32'},
          {name='all_num', type='uint32'},
          {name='s_day_num', type='uint32'},
          {name='s_all_num', type='uint32'}
      }}
   },
   [16689] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='num', type='uint32'}
   },
   [16690] = {
      {name='predict_data', type='array', fields={
          {name='type', type='uint32'},
          {name='count', type='uint32'},
          {name='rand_lists', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='flag', type='uint32'}
      }},
      {name='time', type='uint32'},
      {name='ref_1', type='uint32'},
      {name='ref_2', type='uint32'},
      {name='buy_1', type='uint32'},
      {name='buy_2', type='uint32'},
      {name='status_1', type='uint32'},
      {name='status_2', type='uint32'}
   },
   [16691] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type1', type='uint32'},
      {name='type', type='uint32'},
      {name='count', type='uint32'},
      {name='rand_lists', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='flag', type='uint32'},
      {name='ref_count', type='uint32'}
   },
   [16692] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16693] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type1', type='uint32'},
      {name='ref_count', type='uint32'},
      {name='type', type='uint32'},
      {name='count', type='uint32'},
      {name='rand_lists', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='flag', type='uint32'}
   },
   [16694] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint32'}
   },
   [16695] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16696] = {
      {name='code', type='uint8'}
   },
   [16697] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='camp_id', type='uint32'},
      {name='id', type='uint32'}
   },
   [16698] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16700] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='name', type='string'},
          {name='need_rmb', type='uint32'},
          {name='get_gold', type='uint32'},
          {name='add_gold', type='uint32'},
          {name='is_first', type='uint8'},
          {name='pic', type='uint8'}
      }}
   },
   [16705] = {
      {name='card1_is_reward', type='uint8'},
      {name='card1_end_time', type='uint32'},
      {name='card1_days', type='uint16'},
      {name='card1_acc', type='uint16'},
      {name='card2_is_reward', type='uint8'},
      {name='card2_end_time', type='uint32'},
      {name='card2_days', type='uint16'},
      {name='card2_acc', type='uint16'}
   },
   [16706] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='card_type', type='uint8'}
   },
   [16707] = {
      {name='status', type='uint8'}
   },
   [16708] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16710] = {
      {name='list', type='array', fields={
          {name='lev', type='uint8'}
      }}
   },
   [16711] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16712] = {
      {name='charge_sum', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [16713] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [16800] = {
      {name='type', type='uint8'},
      {name='arg_uint32', type='array', fields={
          {name='key', type='uint8'},
          {name='value', type='uint32'}
      }},
      {name='arg_str', type='array', fields={
          {name='key', type='uint8'},
          {name='value', type='string'}
      }},
      {name='idx', type='uint32'}
   },
   [16801] = {
      {name='buff_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='remain_seconds', type='uint32'}
      }}
   },
   [16802] = {
      {name='bid', type='uint32'}
   },
   [16900] = {
      {name='lev', type='uint8'},
      {name='exp', type='uint32'},
      {name='day_exp', type='uint32'},
      {name='week_exp', type='uint32'}
   },
   [16901] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [16902] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [16903] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [16904] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [19800] = {
      {name='code', type='uint32'}
   },
   [19801] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [19802] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='vip', type='uint8'},
          {name='sex', type='uint8'},
          {name='online', type='uint8'},
          {name='power', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='is_return', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [19803] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='vip', type='uint8'},
      {name='sex', type='uint8'},
      {name='online', type='uint8'},
      {name='power', type='uint32'},
      {name='face_id', type='uint32'},
      {name='avatar_bid', type='uint32'},
      {name='is_return', type='uint8'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [19804] = {
      {name='list', type='array', fields={
          {name='id', type='uint8'},
          {name='num', type='uint8'},
          {name='had', type='uint8'}
      }}
   },
   [19805] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'},
      {name='num', type='uint8'},
      {name='had', type='uint8'}
   },
   [19806] = {
      {name='status', type='uint8'}
   },
   [19807] = {
      {name='code', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='vip', type='uint8'},
      {name='online', type='uint8'},
      {name='power', type='uint32'},
      {name='face_id', type='uint32'},
      {name='avatar_bid', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [19810] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [19811] = {
      {name='list', type='array', fields={
          {name='id', type='uint8'},
          {name='num', type='uint8'},
          {name='had', type='uint8'}
      }}
   },
   [19812] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'},
      {name='num', type='uint8'},
      {name='had', type='uint8'}
   },
   [19901] = {
      {name='type', type='uint8'},
      {name='replay_list', type='array', fields={
          {name='name', type='string'},
          {name='flag', type='int8'},
          {name='is_collect', type='int8'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='id', type='uint32'},
          {name='combat_type', type='uint8'},
          {name='round', type='uint8'},
          {name='sec_type', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_power', type='uint32'},
          {name='a_rank', type='uint8'},
          {name='a_formation_type', type='uint8'},
          {name='a_camp_type', type='uint8'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_power', type='uint32'},
          {name='b_rank', type='uint8'},
          {name='b_formation_type', type='uint8'},
          {name='b_camp_type', type='uint8'},
          {name='ret', type='uint8'},
          {name='like', type='uint32'},
          {name='share', type='uint32'},
          {name='play', type='uint32'},
          {name='time', type='uint32'},
          {name='a_plist', type='array', fields={
              {name='id', type='uint32'},
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='hp', type='uint32'},
              {name='hp_max', type='uint32'},
              {name='dps', type='uint32'},
              {name='be_hurt', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_plist', type='array', fields={
              {name='id', type='uint32'},
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='hp', type='uint32'},
              {name='hp_max', type='uint32'},
              {name='dps', type='uint32'},
              {name='be_hurt', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'},
              {name='str', type='string'},
              {name='ext_list', type='array', fields={
                  {name='ext_list_key', type='uint32'},
                  {name='ext_list_val', type='uint32'}
              }}
          }}
      }}
   },
   [19902] = {
      {name='type', type='uint8'},
      {name='cond_type', type='uint32'},
      {name='start', type='uint32'},
      {name='num', type='uint8'},
      {name='len', type='uint32'},
      {name='replay_list', type='array', fields={
          {name='name', type='string'},
          {name='flag', type='int8'},
          {name='is_collect', type='int8'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='id', type='uint32'},
          {name='combat_type', type='uint8'},
          {name='round', type='uint8'},
          {name='sec_type', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_power', type='uint32'},
          {name='a_rank', type='uint8'},
          {name='a_formation_type', type='uint8'},
          {name='a_camp_type', type='uint8'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_power', type='uint32'},
          {name='b_rank', type='uint8'},
          {name='b_formation_type', type='uint8'},
          {name='b_camp_type', type='uint8'},
          {name='ret', type='uint8'},
          {name='like', type='uint32'},
          {name='share', type='uint32'},
          {name='play', type='uint32'},
          {name='time', type='uint32'},
          {name='a_plist', type='array', fields={
              {name='id', type='uint32'},
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='hp', type='uint32'},
              {name='hp_max', type='uint32'},
              {name='dps', type='uint32'},
              {name='be_hurt', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_plist', type='array', fields={
              {name='id', type='uint32'},
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='hp', type='uint32'},
              {name='hp_max', type='uint32'},
              {name='dps', type='uint32'},
              {name='be_hurt', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'},
              {name='str', type='string'},
              {name='ext_list', type='array', fields={
                  {name='ext_list_key', type='uint32'},
                  {name='ext_list_val', type='uint32'}
              }}
          }}
      }}
   },
   [19903] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [19904] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='type', type='uint8'}
   },
   [19905] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [19906] = {
      {name='like', type='uint8'}
   },
   [19907] = {
      {name='replay_id', type='uint32'},
      {name='partner_id', type='uint32'},
      {name='type', type='uint8'},
      {name='pos', type='uint8'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='break_lev', type='uint8'},
      {name='power', type='uint32'},
      {name='now_hp', type='uint32'},
      {name='hp', type='uint32'},
      {name='atk', type='uint32'},
      {name='def', type='uint32'},
      {name='speed', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='dps', type='uint32'},
      {name='behurt', type='uint32'},
      {name='cure', type='uint32'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_bid', type='uint32'}
      }},
      {name='eqms', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='type', type='uint32'}
      }},
      {name='artifacts', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='artifact_pos', type='uint8'},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }},
      {name='ext', type='array', fields={
          {name='key', type='uint32'},
          {name='val', type='uint32'}
      }}
   },
   [19908] = {
      {name='type', type='uint8'},
      {name='channel', type='uint16'},
      {name='name', type='string'},
      {name='flag', type='int8'},
      {name='is_collect', type='int8'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='id', type='uint32'},
      {name='combat_type', type='uint8'},
      {name='round', type='uint8'},
      {name='sec_type', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_power', type='uint32'},
      {name='a_rank', type='uint8'},
      {name='a_formation_type', type='uint8'},
      {name='a_camp_type', type='uint8'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_power', type='uint32'},
      {name='b_rank', type='uint8'},
      {name='b_formation_type', type='uint8'},
      {name='b_camp_type', type='uint8'},
      {name='ret', type='uint8'},
      {name='like', type='uint32'},
      {name='share', type='uint32'},
      {name='play', type='uint32'},
      {name='time', type='uint32'},
      {name='a_plist', type='array', fields={
          {name='id', type='uint32'},
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='hp', type='uint32'},
          {name='hp_max', type='uint32'},
          {name='dps', type='uint32'},
          {name='be_hurt', type='uint32'},
          {name='cure', type='uint32'},
          {name='ext', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='b_plist', type='array', fields={
          {name='id', type='uint32'},
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='hp', type='uint32'},
          {name='hp_max', type='uint32'},
          {name='dps', type='uint32'},
          {name='be_hurt', type='uint32'},
          {name='cure', type='uint32'},
          {name='ext', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='ext', type='array', fields={
          {name='key', type='uint32'},
          {name='val', type='uint32'},
          {name='str', type='string'},
          {name='ext_list', type='array', fields={
              {name='ext_list_key', type='uint32'},
              {name='ext_list_val', type='uint32'}
          }}
      }}
   },
   [20000] = {
      {name='combat_type', type='uint16'},
      {name='combat_map', type='uint32'}
   },
   [20001] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20002] = {
      {name='pos', type='uint16'},
      {name='owner_id', type='uint32'},
      {name='owner_srv_id', type='string'},
      {name='all_alive', type='array', fields={
          {name='pos', type='uint16'}
      }},
      {name='skill_plays', type='array', fields={
          {name='order', type='uint8'},
          {name='actor', type='uint16'},
          {name='target', type='uint16'},
          {name='skill_bid', type='uint32'},
          {name='talk_pos', type='uint16'},
          {name='talk_content', type='string'},
          {name='effect_play', type='array', fields={
              {name='order', type='uint16'},
              {name='actor', type='uint16'},
              {name='target', type='uint16'},
              {name='effect_bid', type='uint32'},
              {name='is_hit', type='uint8'},
              {name='is_crit', type='uint8'},
              {name='hp_changed', type='int32'},
              {name='hp', type='uint64'},
              {name='is_dead', type='int8'},
              {name='camp_restrain', type='int8'},
              {name='buff_list', type='array', fields={
                  {name='target', type='uint16'},
                  {name='buff_bid', type='uint32'},
                  {name='remain_round', type='uint16'},
                  {name='end_round', type='uint8'},
                  {name='action_type', type='uint8'},
                  {name='change_type', type='uint8'},
                  {name='change_value', type='int32'},
                  {name='is_dead', type='int8'},
                  {name='id', type='uint32'}
              }},
              {name='summon_list', type='array', fields={
                  {name='pos', type='uint16'},
                  {name='group', type='uint8'},
                  {name='owner_id', type='uint32'},
                  {name='owner_srv_id', type='string'},
                  {name='object_type', type='uint16'},
                  {name='object_id', type='uint32'},
                  {name='object_bid', type='uint32'},
                  {name='object_name', type='string'},
                  {name='star', type='uint8'},
                  {name='camp_type', type='int8'},
                  {name='sex', type='int8'},
                  {name='career', type='int8'},
                  {name='lev', type='uint32'},
                  {name='hp', type='uint64'},
                  {name='hp_max', type='uint64'},
                  {name='face_id', type='int32'},
                  {name='skills', type='array', fields={
                      {name='skill_bid', type='uint32'},
                      {name='end_round', type='int8'}
                  }},
                  {name='extra_data', type='array', fields={
                      {name='extra_key', type='uint8'},
                      {name='extra_value', type='uint32'}
                  }},
                  {name='sprites', type='array', fields={
                      {name='pos', type='uint8'},
                      {name='item_bid', type='uint32'}
                  }}
              }},
              {name='sub_effect_play_list', type='array', fields={
                  {name='sub_target', type='uint16'},
                  {name='sub_effect_id', type='uint32'},
                  {name='sub_hp_changed', type='int32'},
                  {name='sub_is_hit', type='uint8'},
                  {name='sub_skill_id', type='uint32'},
                  {name='extra_effect', type='array', fields={
                      {name='extra_key', type='uint16'},
                      {name='extra_param', type='int32'}
                  }}
              }},
              {name='is_blind', type='uint8'},
              {name='skill_bid_of_effect', type='uint32'},
              {name='actor_hp_changed', type='int32'},
              {name='actor_is_dead', type='int8'},
              {name='aid_actor', type='uint16'},
              {name='total_hurt', type='uint32'},
              {name='hurt_reward', type='array', fields={
                  {name='assets_id', type='uint32'},
                  {name='assets_val', type='int32'}
              }}
          }}
      }},
      {name='round_buff', type='array', fields={
          {name='target', type='uint16'},
          {name='buff_bid', type='uint32'},
          {name='remain_round', type='uint16'},
          {name='end_round', type='uint8'},
          {name='action_type', type='uint8'},
          {name='change_type', type='uint8'},
          {name='change_value', type='int32'},
          {name='is_dead', type='int8'},
          {name='id', type='uint32'}
      }},
      {name='countdown_time', type='uint32'},
      {name='action_count', type='uint32'},
      {name='combat_type', type='uint16'},
      {name='hallows_list', type='array', fields={
          {name='group', type='uint8'},
          {name='val', type='uint8'}
      }},
      {name='sprite_cd_info', type='array', fields={
          {name='pos', type='uint16'},
          {name='cd_info', type='array', fields={
              {name='skill_bid', type='uint32'},
              {name='end_round', type='int8'}
          }}
      }}
   },
   [20004] = {
      {name='skill_plays', type='array', fields={
          {name='order', type='uint8'},
          {name='actor', type='uint16'},
          {name='target', type='uint16'},
          {name='skill_bid', type='uint32'},
          {name='talk_pos', type='uint16'},
          {name='talk_content', type='string'},
          {name='effect_play', type='array', fields={
              {name='order', type='uint16'},
              {name='actor', type='uint16'},
              {name='target', type='uint16'},
              {name='effect_bid', type='uint32'},
              {name='is_hit', type='uint8'},
              {name='is_crit', type='uint8'},
              {name='hp_changed', type='int32'},
              {name='hp', type='uint64'},
              {name='is_dead', type='int8'},
              {name='camp_restrain', type='int8'},
              {name='buff_list', type='array', fields={
                  {name='target', type='uint16'},
                  {name='buff_bid', type='uint32'},
                  {name='remain_round', type='uint16'},
                  {name='end_round', type='uint8'},
                  {name='action_type', type='uint8'},
                  {name='change_type', type='uint8'},
                  {name='change_value', type='int32'},
                  {name='is_dead', type='int8'},
                  {name='id', type='uint32'}
              }},
              {name='summon_list', type='array', fields={
                  {name='pos', type='uint16'},
                  {name='group', type='uint8'},
                  {name='owner_id', type='uint32'},
                  {name='owner_srv_id', type='string'},
                  {name='object_type', type='uint16'},
                  {name='object_id', type='uint32'},
                  {name='object_bid', type='uint32'},
                  {name='object_name', type='string'},
                  {name='star', type='uint8'},
                  {name='camp_type', type='int8'},
                  {name='sex', type='int8'},
                  {name='career', type='int8'},
                  {name='lev', type='uint32'},
                  {name='hp', type='uint64'},
                  {name='hp_max', type='uint64'},
                  {name='face_id', type='int32'},
                  {name='skills', type='array', fields={
                      {name='skill_bid', type='uint32'},
                      {name='end_round', type='int8'}
                  }},
                  {name='extra_data', type='array', fields={
                      {name='extra_key', type='uint8'},
                      {name='extra_value', type='uint32'}
                  }},
                  {name='sprites', type='array', fields={
                      {name='pos', type='uint8'},
                      {name='item_bid', type='uint32'}
                  }}
              }},
              {name='sub_effect_play_list', type='array', fields={
                  {name='sub_target', type='uint16'},
                  {name='sub_effect_id', type='uint32'},
                  {name='sub_hp_changed', type='int32'},
                  {name='sub_is_hit', type='uint8'},
                  {name='sub_skill_id', type='uint32'},
                  {name='extra_effect', type='array', fields={
                      {name='extra_key', type='uint16'},
                      {name='extra_param', type='int32'}
                  }}
              }},
              {name='is_blind', type='uint8'},
              {name='skill_bid_of_effect', type='uint32'},
              {name='actor_hp_changed', type='int32'},
              {name='actor_is_dead', type='int8'},
              {name='aid_actor', type='uint16'},
              {name='total_hurt', type='uint32'},
              {name='hurt_reward', type='array', fields={
                  {name='assets_id', type='uint32'},
                  {name='assets_val', type='int32'}
              }}
          }}
      }},
      {name='round_buff', type='array', fields={
          {name='target', type='uint16'},
          {name='buff_bid', type='uint32'},
          {name='remain_round', type='uint16'},
          {name='end_round', type='uint8'},
          {name='action_type', type='uint8'},
          {name='change_type', type='uint8'},
          {name='change_value', type='int32'},
          {name='is_dead', type='int8'},
          {name='id', type='uint32'}
      }},
      {name='action_count', type='uint32'},
      {name='combat_type', type='uint16'},
      {name='star_list', type='array', fields={
          {name='id', type='uint8'},
          {name='val', type='uint8'}
      }},
      {name='sprite_cd_info', type='array', fields={
          {name='pos', type='uint16'},
          {name='cd_info', type='array', fields={
              {name='skill_bid', type='uint32'},
              {name='end_round', type='int8'}
          }}
      }}
   },
   [20005] = {
   },
   [20006] = {
      {name='result', type='uint8'},
      {name='item_rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='is_bind', type='uint8'},
          {name='num', type='uint32'},
          {name='id', type='uint32'}
      }},
      {name='show_panel_type', type='uint8'},
      {name='current_time', type='uint32'},
      {name='best_time', type='uint32'},
      {name='combat_type', type='uint16'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='adventure_end_hp', type='uint32'},
      {name='room_id', type='uint8'},
      {name='ext_list', type='array', fields={
          {name='ext_type', type='uint8'},
          {name='ext_val', type='uint32'}
      }}
   },
   [20008] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20009] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20013] = {
      {name='combat_type', type='uint16'},
      {name='formation', type='array', fields={
          {name='group', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='formation_lev', type='uint8'}
      }},
      {name='objects', type='array', fields={
          {name='pos', type='uint16'},
          {name='group', type='uint8'},
          {name='owner_id', type='uint32'},
          {name='owner_srv_id', type='string'},
          {name='object_type', type='uint16'},
          {name='object_id', type='uint32'},
          {name='object_bid', type='uint32'},
          {name='object_name', type='string'},
          {name='star', type='uint8'},
          {name='camp_type', type='int8'},
          {name='sex', type='int8'},
          {name='career', type='int8'},
          {name='lev', type='uint32'},
          {name='hp', type='uint64'},
          {name='hp_max', type='uint64'},
          {name='face_id', type='int32'},
          {name='skills', type='array', fields={
              {name='skill_bid', type='uint32'},
              {name='end_round', type='int8'}
          }},
          {name='extra_data', type='array', fields={
              {name='extra_key', type='uint8'},
              {name='extra_value', type='uint32'}
          }},
          {name='sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }},
      {name='is_auto', type='uint8'},
      {name='buffs', type='array', fields={
          {name='target', type='uint16'},
          {name='buff_bid', type='uint32'},
          {name='remain_round', type='uint16'},
          {name='end_round', type='uint8'},
          {name='action_type', type='uint8'},
          {name='change_type', type='uint8'},
          {name='change_value', type='int32'},
          {name='is_dead', type='int8'},
          {name='id', type='uint32'}
      }},
      {name='current_wave', type='uint8'},
      {name='total_wave', type='uint16'},
      {name='play_speed', type='uint8'},
      {name='combat_map', type='uint32'},
      {name='extra_args', type='array', fields={
          {name='param', type='uint32'}
      }},
      {name='action_count', type='uint32'},
      {name='a_object_num', type='uint8'},
      {name='target_role_name', type='string'},
      {name='actor_role_name', type='string'},
      {name='begin_time', type='uint32'},
      {name='suppress', type='uint8'},
      {name='flag', type='uint8'},
      {name='halo_list', type='array', fields={
          {name='group', type='uint8'},
          {name='type', type='uint32'}
      }},
      {name='hallows_list', type='array', fields={
          {name='group', type='uint8'},
          {name='val', type='uint8'},
          {name='max', type='uint8'}
      }},
      {name='cli_string_ext_args', type='array', fields={
          {name='param', type='string'}
      }}
   },
   [20014] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20015] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20016] = {
      {name='target_id', type='uint32'},
      {name='target_srv_id', type='string'},
      {name='target_name', type='string'},
      {name='target_lev', type='uint8'},
      {name='target_face', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [20019] = {
   },
   [20020] = {
      {name='combat_type', type='uint16'},
      {name='formation', type='array', fields={
          {name='group', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='formation_lev', type='uint8'}
      }},
      {name='objects', type='array', fields={
          {name='pos', type='uint16'},
          {name='group', type='uint8'},
          {name='owner_id', type='uint32'},
          {name='owner_srv_id', type='string'},
          {name='object_type', type='uint16'},
          {name='object_id', type='uint32'},
          {name='object_bid', type='uint32'},
          {name='object_name', type='string'},
          {name='star', type='uint8'},
          {name='camp_type', type='int8'},
          {name='sex', type='int8'},
          {name='career', type='int8'},
          {name='lev', type='uint32'},
          {name='hp', type='uint64'},
          {name='hp_max', type='uint64'},
          {name='face_id', type='int32'},
          {name='skills', type='array', fields={
              {name='skill_bid', type='uint32'},
              {name='end_round', type='int8'}
          }},
          {name='extra_data', type='array', fields={
              {name='extra_key', type='uint8'},
              {name='extra_value', type='uint32'}
          }},
          {name='sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }},
      {name='is_auto', type='uint8'},
      {name='buffs', type='array', fields={
          {name='target', type='uint16'},
          {name='buff_bid', type='uint32'},
          {name='remain_round', type='uint16'},
          {name='end_round', type='uint8'},
          {name='action_type', type='uint8'},
          {name='change_type', type='uint8'},
          {name='change_value', type='int32'},
          {name='is_dead', type='int8'},
          {name='id', type='uint32'}
      }},
      {name='current_wave', type='uint8'},
      {name='total_wave', type='uint16'},
      {name='target_role_name', type='string'},
      {name='actor_role_name', type='string'},
      {name='halo_list', type='array', fields={
          {name='group', type='uint8'},
          {name='type', type='uint32'}
      }}
   },
   [20022] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20026] = {
      {name='drama_id', type='uint32'}
   },
   [20027] = {
      {name='combat_type', type='uint16'},
      {name='formation', type='array', fields={
          {name='group', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='formation_lev', type='uint8'}
      }},
      {name='objects', type='array', fields={
          {name='pos', type='uint16'},
          {name='group', type='uint8'},
          {name='owner_id', type='uint32'},
          {name='owner_srv_id', type='string'},
          {name='object_type', type='uint16'},
          {name='object_id', type='uint32'},
          {name='object_bid', type='uint32'},
          {name='object_name', type='string'},
          {name='star', type='uint8'},
          {name='camp_type', type='int8'},
          {name='sex', type='int8'},
          {name='career', type='int8'},
          {name='lev', type='uint32'},
          {name='hp', type='uint64'},
          {name='hp_max', type='uint64'},
          {name='face_id', type='int32'},
          {name='skills', type='array', fields={
              {name='skill_bid', type='uint32'},
              {name='end_round', type='int8'}
          }},
          {name='extra_data', type='array', fields={
              {name='extra_key', type='uint8'},
              {name='extra_value', type='uint32'}
          }},
          {name='sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }},
      {name='is_auto', type='uint8'},
      {name='current_wave', type='uint8'},
      {name='total_wave', type='uint16'},
      {name='play_speed', type='uint8'},
      {name='extra_args', type='array', fields={
          {name='param', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='a_object_num', type='uint8'},
      {name='actor_role_name', type='string'},
      {name='suppress', type='uint8'},
      {name='halo_list', type='array', fields={
          {name='group', type='uint8'},
          {name='type', type='uint32'}
      }},
      {name='hallows_list', type='array', fields={
          {name='group', type='uint8'},
          {name='val', type='uint8'},
          {name='max', type='uint8'}
      }},
      {name='string_ext_args', type='array', fields={
          {name='param', type='string'}
      }}
   },
   [20028] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20029] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20030] = {
      {name='is_in_combat', type='uint8'}
   },
   [20033] = {
      {name='result', type='uint8'},
      {name='def_name', type='string'},
      {name='def_guild_name', type='string'},
      {name='def_lev', type='uint32'},
      {name='def_face_id', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='replay_id', type='uint32'},
      {name='is_province', type='uint8'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [20034] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [20036] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20060] = {
      {name='combat_type', type='uint16'},
      {name='type', type='uint8'}
   },
   [20061] = {
      {name='combat_type', type='uint16'},
      {name='bid', type='uint32'},
      {name='partner_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='speed', type='uint16'},
          {name='bid', type='uint32'},
          {name='lev', type='uint8'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='hp', type='uint32'},
          {name='crit', type='uint16'},
          {name='skill_list', type='array', fields={
              {name='sid', type='uint32'},
              {name='effect_list', type='array', fields={
                  {name='eid', type='uint32'},
                  {name='num', type='uint8'},
                  {name='min_hurt', type='uint32'},
                  {name='max_hurt', type='uint32'}
              }},
              {name='rand', type='uint8'}
          }},
          {name='use_skin', type='uint32'}
      }},
      {name='wave_list', type='array', fields={
          {name='unit_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='speed', type='uint16'},
              {name='hp', type='uint32'},
              {name='crit', type='uint16'},
              {name='skill_list', type='array', fields={
                  {name='sid', type='uint32'},
                  {name='effect_list', type='array', fields={
                      {name='eid', type='uint32'},
                      {name='num', type='uint8'},
                      {name='min_hurt', type='uint32'},
                      {name='max_hurt', type='uint32'}
                  }},
                  {name='rand', type='uint8'}
              }}
          }}
      }},
      {name='dun_bid', type='uint32'},
      {name='b_formation_type', type='uint8'}
   },
   [20062] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20063] = {
      {name='type_list', type='array', fields={
          {name='combat_type', type='uint16'}
      }}
   },
   [20200] = {
      {name='rank', type='uint16'},
      {name='score', type='uint32'},
      {name='can_combat_num', type='uint8'},
      {name='buy_combat_num', type='uint8'},
      {name='ref_time', type='int32'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='cont_win', type='uint16'}
   },
   [20201] = {
      {name='f_list', type='array', fields={
          {name='idx', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='score', type='uint32'},
          {name='get_score', type='uint8'},
          {name='status', type='uint8'},
          {name='p_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='use_skin', type='uint32'},
              {name='resonate_lev', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='gname', type='string'}
      }},
      {name='type', type='uint8'}
   },
   [20202] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint16'},
      {name='face', type='uint32'},
      {name='power', type='uint32'},
      {name='score', type='uint32'},
      {name='formation_type', type='uint8'},
      {name='formation_lev', type='uint8'},
      {name='p_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='use_skin', type='uint32'},
          {name='resonate_lev', type='uint32'}
      }},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='gname', type='string'}
   },
   [20203] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20204] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20206] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20207] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20208] = {
      {name='had_combat_num', type='uint16'},
      {name='num_list', type='array', fields={
          {name='num', type='uint8'}
      }}
   },
   [20209] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20210] = {
      {name='result', type='uint8'},
      {name='score', type='uint32'},
      {name='get_score', type='int32'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='tar_name', type='string'},
      {name='tar_lev', type='uint16'},
      {name='tar_face', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='tar_score', type='int32'},
      {name='lose_score', type='int32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='replay_id', type='uint32'}
   },
   [20220] = {
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='rank', type='uint8'},
          {name='score', type='uint32'},
          {name='sex', type='uint8'},
          {name='lookid', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [20221] = {
      {name='rank', type='uint16'},
      {name='score', type='uint32'},
      {name='worship', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='score', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='lookid', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [20222] = {
      {name='log_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='power', type='uint32'},
          {name='score', type='int16'},
          {name='type', type='uint8'},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='time', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [20223] = {
      {name='flag', type='uint8'}
   },
   [20250] = {
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='step', type='uint8'},
      {name='step_status', type='uint8'},
      {name='step_status_time', type='uint32'},
      {name='round', type='uint8'},
      {name='round_status', type='uint8'},
      {name='round_status_time', type='uint32'},
      {name='flag', type='uint8'}
   },
   [20251] = {
      {name='rank', type='uint16'},
      {name='best_rank', type='uint16'},
      {name='can_bet', type='uint32'},
      {name='group', type='uint8'}
   },
   [20252] = {
      {name='step', type='uint8'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_formation_type', type='uint8'},
      {name='a_formation_lev', type='uint8'},
      {name='a_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_formation_type', type='uint8'},
      {name='b_formation_lev', type='uint8'},
      {name='b_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='ret', type='uint8'},
      {name='replay_id', type='uint32'},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [20253] = {
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'},
      {name='a_bet_ratio', type='uint16'},
      {name='b_bet_ratio', type='uint16'},
      {name='step', type='uint8'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_formation_type', type='uint8'},
      {name='a_formation_lev', type='uint8'},
      {name='a_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_formation_type', type='uint8'},
      {name='b_formation_lev', type='uint8'},
      {name='b_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='ret', type='uint8'},
      {name='replay_id', type='uint32'},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [20254] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='can_bet', type='uint32'},
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'}
   },
   [20255] = {
      {name='list', type='array', fields={
          {name='id', type='uint16'},
          {name='target', type='uint8'},
          {name='bet', type='uint32'},
          {name='get_bet', type='uint32'},
          {name='step', type='uint8'},
          {name='round', type='uint8'},
          {name='group', type='uint8'},
          {name='a_bet', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='a_avatar_id', type='uint32'},
          {name='a_sex', type='uint8'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint8'},
          {name='a_formation_lev', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_bet', type='uint32'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='b_avatar_id', type='uint32'},
          {name='b_sex', type='uint8'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint8'},
          {name='b_formation_lev', type='uint8'},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [20256] = {
      {name='rank', type='uint16'},
      {name='cnum', type='uint8'},
      {name='win', type='uint8'}
   },
   [20257] = {
      {name='a_bet', type='uint32'},
      {name='b_bet', type='uint32'},
      {name='a_bet_ratio', type='uint16'},
      {name='b_bet_ratio', type='uint16'}
   },
   [20258] = {
      {name='list', type='array', fields={
          {name='id', type='uint16'},
          {name='score', type='uint16'},
          {name='step', type='uint8'},
          {name='round', type='uint8'},
          {name='group', type='uint8'},
          {name='a_bet', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='a_avatar_id', type='uint32'},
          {name='a_sex', type='uint8'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint8'},
          {name='a_formation_lev', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_bet', type='uint32'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='b_avatar_id', type='uint32'},
          {name='b_sex', type='uint8'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint8'},
          {name='b_formation_lev', type='uint8'},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [20260] = {
      {name='list', type='array', fields={
          {name='group', type='uint8'},
          {name='pos_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='rid', type='uint32'},
              {name='srv_id', type='string'},
              {name='name', type='string'},
              {name='ret', type='uint8'},
              {name='replay_id', type='uint32'}
          }}
      }}
   },
   [20261] = {
      {name='pos_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='face', type='uint32'},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [20262] = {
      {name='group', type='uint8'},
      {name='pos', type='uint8'}
   },
   [20263] = {
      {name='step', type='uint8'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_formation_type', type='uint8'},
      {name='a_formation_lev', type='uint8'},
      {name='a_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_formation_type', type='uint8'},
      {name='b_formation_lev', type='uint8'},
      {name='b_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='ret', type='uint8'},
      {name='replay_id', type='uint32'},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [20280] = {
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='rank', type='uint8'},
          {name='sex', type='uint8'},
          {name='lookid', type='uint32'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [20281] = {
      {name='rank', type='uint16'},
      {name='worship', type='uint32'},
      {name='power', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='score', type='uint16'},
          {name='power', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [20282] = {
      {name='time', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [20300] = {
      {name='activity_box', type='array', fields={
          {name='activity', type='uint16'}
      }}
   },
   [20301] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='activity', type='uint8'}
   },
   [20500] = {
      {name='boss_list', type='array', fields={
          {name='boss_id', type='uint32'},
          {name='status', type='uint8'},
          {name='first', type='uint8'}
      }},
      {name='ext_list', type='array', fields={
          {name='ext_id', type='uint8'},
          {name='status', type='uint8'}
      }}
   },
   [20501] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20502] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20530] = {
      {name='can_combat_num', type='uint8'},
      {name='buy_combat_num', type='uint8'},
      {name='num_time', type='uint32'}
   },
   [20531] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20532] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20533] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20535] = {
      {name='boss_list', type='array', fields={
          {name='boss_id', type='uint32'},
          {name='rnum', type='uint16'},
          {name='hp', type='uint32'},
          {name='hp_max', type='uint32'},
          {name='ref_time', type='uint32'}
      }}
   },
   [20536] = {
      {name='boss_id', type='uint32'},
      {name='rnum', type='uint16'},
      {name='hp', type='uint32'},
      {name='hp_max', type='uint32'},
      {name='ref_time', type='uint32'}
   },
   [20537] = {
      {name='boss_id', type='uint32'},
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='hurt', type='uint32'}
      }}
   },
   [20538] = {
      {name='boss_id', type='uint32'},
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='power', type='uint32'},
          {name='time', type='uint32'}
      }}
   },
   [20539] = {
      {name='boss_id', type='uint32'},
      {name='hurt', type='uint32'},
      {name='item_rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='is_bind', type='uint8'},
          {name='num', type='uint32'},
          {name='id', type='uint32'}
      }}
   },
   [20540] = {
      {name='boss_list', type='array', fields={
          {name='boss_id', type='uint32'}
      }}
   },
   [20541] = {
   },
   [20542] = {
      {name='result', type='uint8'},
      {name='first_award', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='award', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [20600] = {
      {name='pass_id', type='uint8'},
      {name='pass_num', type='uint8'},
      {name='id', type='uint8'},
      {name='room', type='uint8'},
      {name='is_kill_boss', type='uint8'},
      {name='map_id', type='uint8'},
      {name='is_all_finish', type='uint8'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='current_id', type='uint8'}
   },
   [20601] = {
      {name='buff_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='time', type='uint32'}
      }},
      {name='holiday_buff_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='time', type='uint32'}
      }}
   },
   [20602] = {
      {name='room_list', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'},
          {name='lock', type='uint8'},
          {name='evt_id', type='uint32'},
          {name='res_id', type='uint8'}
      }}
   },
   [20603] = {
      {name='room_list', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'},
          {name='lock', type='uint8'},
          {name='evt_id', type='uint32'},
          {name='res_id', type='uint8'}
      }}
   },
   [20604] = {
      {name='id', type='uint32'},
      {name='combat_num', type='uint32'},
      {name='partners', type='array', fields={
          {name='now_hp', type='uint32'},
          {name='partner_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='skills', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_bid', type='uint32'}
          }},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='is_lock', type='array', fields={
              {name='lock_type', type='uint32'},
              {name='is_lock', type='uint8'}
          }},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint32'},
          {name='resonate_lev', type='uint32'},
          {name='resonate_break_lev', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'},
          {name='atk2', type='uint32'},
          {name='hp2', type='uint32'},
          {name='def2', type='uint32'},
          {name='speed2', type='uint32'},
          {name='eqms', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'}
          }},
          {name='artifacts', type='array', fields={
              {name='artifact_pos', type='uint8'},
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='enchant', type='uint32'},
              {name='attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }},
          {name='dower_skill', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_id', type='uint32'}
          }}
      }}
   },
   [20605] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='last_num', type='uint16'}
   },
   [20606] = {
      {name='items_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='vip_buff', type='uint32'}
   },
   [20607] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20608] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='room_id', type='uint8'}
   },
   [20609] = {
      {name='skill_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'},
          {name='use_count', type='uint32'}
      }}
   },
   [20610] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [20611] = {
      {name='room_list', type='array', fields={
          {name='id', type='uint8'},
          {name='evt_id', type='uint32'}
      }}
   },
   [20612] = {
   },
   [20620] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='room_id', type='uint8'},
      {name='action', type='uint8'}
   },
   [20621] = {
      {name='sel_val', type='uint8'},
      {name='ret_val', type='uint8'},
      {name='ret', type='uint8'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'},
          {name='move_to', type='uint8'}
      }}
   },
   [20623] = {
      {name='ret', type='uint8'},
      {name='sel_val', type='uint8'},
      {name='right', type='uint8'},
      {name='num', type='uint8'},
      {name='max', type='uint8'},
      {name='bid', type='uint32'},
      {name='ret_msg', type='string'},
      {name='now_items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='max_items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='ret_items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'},
          {name='move_to', type='uint8'}
      }}
   },
   [20624] = {
      {name='hp_per', type='uint8'}
   },
   [20625] = {
      {name='id', type='uint8'},
      {name='skill_id', type='uint32'}
   },
   [20627] = {
      {name='evt_id', type='uint32'},
      {name='id', type='uint8'}
   },
   [20628] = {
      {name='msg', type='string'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'},
          {name='move_to', type='uint8'}
      }}
   },
   [20630] = {
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'},
          {name='move_to', type='uint8'}
      }}
   },
   [20631] = {
      {name='type', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='pay_type', type='uint8'},
          {name='pay_val', type='uint32'},
          {name='bid', type='uint32'},
          {name='num', type='uint32'},
          {name='is_buy', type='uint8'},
          {name='discount', type='uint8'}
      }}
   },
   [20632] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='pay_type', type='uint8'},
          {name='pay_val', type='uint32'},
          {name='bid', type='uint32'},
          {name='num', type='uint32'},
          {name='is_buy', type='uint8'},
          {name='discount', type='uint8'}
      }}
   },
   [20633] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [20634] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }},
      {name='kill_mon', type='uint32'}
   },
   [20635] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20636] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20640] = {
      {name='floor', type='uint8'},
      {name='count', type='uint8'},
      {name='occupy_count', type='uint8'},
      {name='list', type='array', fields={
          {name='room_id', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='lev', type='uint16'},
          {name='name', type='string'},
          {name='mine_id', type='uint32'},
          {name='face', type='uint32'},
          {name='status', type='uint8'}
      }},
      {name='buy_count', type='uint8'}
   },
   [20641] = {
      {name='room_id', type='uint8'},
      {name='mine_id', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint16'},
      {name='face', type='uint32'},
      {name='power', type='uint32'},
      {name='plunder_count', type='uint8'},
      {name='occupy_time', type='uint32'},
      {name='defense', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='use_skin', type='uint32'}
      }},
      {name='items', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='id', type='uint8'},
      {name='hallows_id', type='uint32'}
   },
   [20642] = {
      {name='defense', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [20643] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20644] = {
      {name='log_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='floor', type='uint8'},
          {name='room_id', type='uint8'},
          {name='mine_id', type='uint32'},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='time', type='uint32'},
          {name='loss', type='array', fields={
              {name='item_id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [20646] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [20647] = {
      {name='had_combat_num', type='uint16'},
      {name='num_list', type='array', fields={
          {name='num', type='uint8'}
      }},
      {name='count', type='uint8'}
   },
   [20648] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='num', type='uint8'}
   },
   [20649] = {
      {name='result', type='uint8'},
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'},
      {name='count', type='uint32'},
      {name='award', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='end_time', type='uint32'}
   },
   [20651] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20652] = {
      {name='mine_list', type='array', fields={
          {name='floor', type='uint8'},
          {name='room_id', type='uint8'},
          {name='mine_id', type='uint32'},
          {name='occupy_time', type='uint32'},
          {name='primary_count', type='uint8'},
          {name='senior_count', type='uint8'},
          {name='hook_items', type='array', fields={
              {name='item_id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [20653] = {
      {name='floor_list', type='array', fields={
          {name='floor', type='uint8'}
      }}
   },
   [20654] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'},
      {name='type', type='uint8'}
   },
   [20655] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'}
   },
   [20656] = {
      {name='floor', type='uint8'},
      {name='room_id', type='uint8'}
   },
   [20657] = {
      {name='code', type='uint8'}
   },
   [20658] = {
      {name='list', type='array', fields={
          {name='floor', type='uint8'},
          {name='room_id', type='uint8'},
          {name='hallows_id', type='uint32'}
      }}
   },
   [20659] = {
      {name='code', type='uint8'}
   },
   [20660] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20700] = {
      {name='num', type='uint8'},
      {name='time', type='uint32'}
   },
   [20701] = {
      {name='list', type='array', fields={
          {name='pos', type='uint8'},
          {name='num', type='uint32'},
          {name='status', type='uint8'},
          {name='look_id', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face_id', type='uint32'},
          {name='unit_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [20702] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [20703] = {
      {name='pos', type='uint8'},
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='power', type='uint32'},
          {name='face_id', type='uint32'},
          {name='time', type='uint32'},
          {name='num', type='uint32'},
          {name='replay_id', type='uint32'},
          {name='formation_type', type='uint8'},
          {name='formation_lev', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='partner_list', type='array', fields={
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'}
          }}
      }}
   },
   [20705] = {
      {name='pos', type='uint8'},
      {name='num1', type='uint32'},
      {name='num2', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [20706] = {
      {name='is_show', type='uint8'}
   },
   [21000] = {
      {name='end_time', type='uint32'},
      {name='first_gift', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'}
      }}
   },
   [21001] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21002] = {
      {name='count', type='uint16'}
   },
   [21003] = {
   },
   [21004] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21005] = {
      {name='count', type='uint16'},
      {name='gold', type='uint32'},
      {name='next_gold', type='uint32'}
   },
   [21006] = {
      {name='first_gift', type='array', fields={
          {name='id', type='uint8'},
          {name='count', type='uint16'}
      }}
   },
   [21007] = {
      {name='type', type='uint8'},
      {name='ref_time', type='uint32'},
      {name='reg_day', type='uint32'},
      {name='first_gift', type='array', fields={
          {name='id', type='uint32'},
          {name='count', type='uint16'}
      }}
   },
   [21008] = {
      {name='status', type='uint8'}
   },
   [21009] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21010] = {
      {name='status', type='uint8'},
      {name='num', type='uint32'}
   },
   [21011] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21012] = {
      {name='choosen_status', type='uint8'},
      {name='has_choosen_id', type='uint8'},
      {name='first_gift', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'}
      }}
   },
   [21013] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21014] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21015] = {
      {name='open_id', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [21016] = {
      {name='charge_id', type='uint32'},
      {name='status', type='uint8'}
   },
   [21020] = {
      {name='status', type='uint8'}
   },
   [21021] = {
      {name='flag', type='uint8'}
   },
   [21022] = {
      {name='open_id', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [21023] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21024] = {
      {name='list', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [21030] = {
      {name='end_time', type='uint32'},
      {name='first_gift', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'}
      }}
   },
   [21031] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21032] = {
      {name='end_time', type='uint32'},
      {name='first_gift', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'}
      }}
   },
   [21033] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21100] = {
      {name='status_list', type='array', fields={
          {name='day', type='uint8'},
          {name='status', type='uint8'}
      }},
      {name='type', type='uint8'}
   },
   [21101] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='day', type='uint8'}
   },
   [21200] = {
      {name='gifts', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'},
          {name='num', type='uint32'}
      }}
   },
   [21201] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [21210] = {
      {name='gifts', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint16'},
          {name='end_time', type='uint32'}
      }}
   },
   [21211] = {
      {name='id', type='uint32'}
   },
   [21300] = {
      {name='fid', type='uint32'},
      {name='max_id', type='uint32'},
      {name='count', type='uint32'},
      {name='buy_count', type='uint16'},
      {name='info', type='array', fields={
          {name='boss_id', type='uint32'},
          {name='hp', type='uint32'}
      }},
      {name='combat_info', type='array', fields={
          {name='boss_id', type='uint32'},
          {name='dps', type='uint32'}
      }},
      {name='buff_lev', type='uint16'},
      {name='buff_end_time', type='uint32'},
      {name='ref_time', type='uint32'},
      {name='worship', type='uint32'},
      {name='coldtime', type='uint32'}
   },
   [21303] = {
      {name='box_list', type='array', fields={
          {name='fid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [21304] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='fid', type='uint32'},
      {name='num', type='uint32'}
   },
   [21305] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21308] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21309] = {
      {name='bossid', type='uint32'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='award_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [21312] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint16'},
      {name='buy_count', type='uint16'},
      {name='type', type='uint8'}
   },
   [21317] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='do_count', type='uint32'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='award_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [21318] = {
      {name='my_name', type='string'},
      {name='my_rank', type='uint32'},
      {name='my_max_id', type='uint8'},
      {name='my_dps', type='uint32'},
      {name='r_rid', type='uint32'},
      {name='r_srvid', type='string'},
      {name='r_name', type='string'},
      {name='face_id', type='uint32'},
      {name='lev', type='uint32'},
      {name='power', type='uint32'},
      {name='avatar_bid', type='uint32'},
      {name='rank_guild', type='array', fields={
          {name='name', type='string'},
          {name='rank', type='uint8'},
          {name='r_name', type='string'},
          {name='max_id', type='uint32'},
          {name='day_dps', type='uint32'}
      }}
   },
   [21319] = {
      {name='rank', type='uint32'},
      {name='mydps', type='uint32'},
      {name='worship', type='uint32'},
      {name='day_worship', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rank', type='uint32'},
          {name='r_rid', type='uint32'},
          {name='r_srvid', type='string'},
          {name='name', type='string'},
          {name='family_name', type='string'},
          {name='all_dps', type='uint32'},
          {name='face_id', type='uint32'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='look_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [21320] = {
      {name='award_list', type='array', fields={
          {name='fid', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [21321] = {
      {name='fid', type='uint32'},
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21322] = {
      {name='code', type='uint8'}
   },
   [21323] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='coldtime', type='uint32'}
   },
   [21401] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21403] = {
      {name='code', type='uint8'}
   },
   [21409] = {
      {name='time', type='uint8'}
   },
   [21410] = {
      {name='type', type='uint8'},
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='camp', type='uint8'},
          {name='lev', type='uint8'},
          {name='status', type='uint8'},
          {name='effect', type='uint8'},
          {name='score', type='uint16'},
          {name='win_acc', type='uint16'},
          {name='win_best', type='uint8'},
          {name='pos_x', type='uint8'},
          {name='pos_y', type='uint8'},
          {name='skill_effect', type='array', fields={
              {name='id', type='uint8'}
          }}
      }}
   },
   [21411] = {
      {name='role_move_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='pos_x', type='uint8'},
          {name='pos_y', type='uint8'}
      }}
   },
   [21412] = {
      {name='score_a', type='uint32'},
      {name='score_b', type='uint32'},
      {name='group', type='uint8'},
      {name='zone', type='uint8'}
   },
   [21413] = {
      {name='type', type='uint8'},
      {name='guard_list', type='array', fields={
          {name='id', type='uint8'},
          {name='camp', type='uint8'},
          {name='bid', type='uint32'},
          {name='pos_x', type='uint8'},
          {name='pos_y', type='uint8'},
          {name='status', type='uint8'},
          {name='hp', type='uint32'},
          {name='max_hp', type='uint32'}
      }}
   },
   [21415] = {
      {name='ret', type='uint8'},
      {name='role_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='camp', type='uint8'},
          {name='lev', type='uint8'},
          {name='score', type='uint16'},
          {name='win_acc', type='uint16'},
          {name='win_best', type='uint8'}
      }}
   },
   [21416] = {
      {name='type', type='uint8'},
      {name='camp1', type='uint8'},
      {name='face1', type='uint32'},
      {name='srv_id1', type='string'},
      {name='name1', type='string'},
      {name='face2', type='uint32'},
      {name='srv_id2', type='string'},
      {name='name2', type='string'}
   },
   [21420] = {
      {name='skill_list', type='array', fields={
          {name='id', type='uint8'},
          {name='cdtime', type='uint32'},
          {name='num', type='uint8'}
      }}
   },
   [21421] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [21425] = {
      {name='group', type='uint8'},
      {name='cnum', type='uint8'},
      {name='win', type='uint8'}
   },
   [21426] = {
      {name='cnum_list', type='array', fields={
          {name='num', type='uint8'}
      }},
      {name='win_list', type='array', fields={
          {name='num', type='uint8'}
      }}
   },
   [21427] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'},
      {name='num', type='uint8'}
   },
   [21500] = {
      {name='avatar_frame', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [21501] = {
      {name='base_id', type='uint32'}
   },
   [21502] = {
      {name='avatar_frame', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [21503] = {
      {name='avatar_frame', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [21504] = {
      {name='attr', type='array', fields={
          {name='key', type='uint8'},
          {name='val', type='uint32'}
      }}
   },
   [22150] = {
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='srv_list', type='array', fields={
          {name='srv_id', type='string'},
          {name='srv_name', type='string'},
          {name='world_lev', type='uint16'},
          {name='open_time', type='uint32'}
      }}
   },
   [22200] = {
      {name='list', type='array', fields={
          {name='id', type='uint8'},
          {name='lev', type='uint8'},
          {name='exp', type='uint32'},
          {name='step', type='uint8'},
          {name='all_attr', type='array', fields={
              {name='name', type='uint8'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [22201] = {
      {name='id', type='uint8'},
      {name='lev', type='uint8'},
      {name='exp', type='uint32'},
      {name='step', type='uint8'},
      {name='all_attr', type='array', fields={
          {name='name', type='uint8'},
          {name='val', type='uint32'}
      }}
   },
   [22202] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [22203] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [22204] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [22205] = {
      {name='id', type='uint8'}
   },
   [22700] = {
      {name='is_cluster', type='uint8'},
      {name='rank_list', type='array', fields={
          {name='id', type='uint8'},
          {name='end_time', type='uint32'}
      }}
   },
   [22701] = {
      {name='id', type='uint8'},
      {name='end_time', type='uint32'},
      {name='rank', type='uint8'},
      {name='rank_list', type='array', fields={
          {name='idx', type='uint8'},
          {name='name', type='string'},
          {name='lev', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [22702] = {
      {name='feat_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }}
   },
   [22703] = {
      {name='feat_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }}
   },
   [22704] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='quest_id', type='uint32'}
   },
   [23100] = {
      {name='dun_id', type='uint32'},
      {name='val', type='uint32'},
      {name='max_val', type='uint32'},
      {name='ids', type='array', fields={
          {name='id', type='uint32'}
      }},
      {name='reward_ids', type='array', fields={
          {name='reward_id', type='uint32'}
      }},
      {name='can_reward_ids', type='array', fields={
          {name='can_reward_id', type='uint32'}
      }},
      {name='update_time', type='uint32'},
      {name='look_id', type='uint32'},
      {name='is_holiday', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [23101] = {
      {name='floor', type='uint32'},
      {name='index', type='uint32'},
      {name='map_id', type='uint32'},
      {name='tile_list', type='array', fields={
          {name='index', type='uint32'},
          {name='evtid', type='uint32'},
          {name='status', type='uint8'},
          {name='is_walk', type='uint8'},
          {name='res_id', type='uint16'},
          {name='platform', type='uint8'},
          {name='switch', type='uint8'},
          {name='is_hide', type='uint8'}
      }},
      {name='walk_tile', type='array', fields={
          {name='pos', type='uint32'}
      }}
   },
   [23102] = {
      {name='floor', type='uint32'},
      {name='tile_list', type='array', fields={
          {name='index', type='uint32'},
          {name='evtid', type='uint32'},
          {name='status', type='uint8'},
          {name='is_walk', type='uint8'},
          {name='res_id', type='uint16'},
          {name='platform', type='uint8'},
          {name='switch', type='uint8'},
          {name='is_hide', type='uint8'}
      }}
   },
   [23103] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='index', type='uint32'}
   },
   [23104] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='index', type='uint32'},
      {name='action', type='uint8'}
   },
   [23105] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='floor', type='uint32'}
   },
   [23106] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23107] = {
      {name='load_partner', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='break_skills', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_bid', type='uint32'}
          }},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'},
          {name='eqms', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'}
          }},
          {name='artifacts', type='array', fields={
              {name='artifact_pos', type='uint8'},
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='enchant', type='uint32'},
              {name='attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }},
          {name='holy_eqm', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='main_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='holy_eqm_attr', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }}
          }},
          {name='dower_skill', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_id', type='uint32'}
          }}
      }}
   },
   [23108] = {
      {name='dun_id', type='uint32'},
      {name='floor', type='uint32'},
      {name='index', type='uint32'},
      {name='ext_list', type='array', fields={
          {name='type', type='uint32'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'}
      }}
   },
   [23109] = {
      {name='power', type='uint32'},
      {name='buffs', type='array', fields={
          {name='quality', type='uint8'},
          {name='num', type='uint32'}
      }},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='face', type='uint32'},
      {name='lev', type='uint8'},
      {name='guards_power', type='uint32'},
      {name='formation_type', type='uint32'},
      {name='guards', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }},
          {name='hp_per', type='uint8'}
      }},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='hallows_id', type='uint32'},
      {name='sprite_lev', type='uint32'},
      {name='strength', type='uint32'}
   },
   [23110] = {
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='use_skin', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='award_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='evt_index', type='uint32'}
   },
   [23111] = {
      {name='id', type='uint32'}
   },
   [23112] = {
      {name='secret_item', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [23113] = {
      {name='update_item', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [23114] = {
      {name='delete_pos', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [23115] = {
      {name='partners', type='array', fields={
          {name='flag', type='uint8'},
          {name='partner_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='power', type='uint32'},
          {name='hp_per', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [23116] = {
      {name='pos', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_bid', type='uint32'}
      }},
      {name='break_lev', type='uint8'},
      {name='power', type='uint32'},
      {name='use_skin', type='uint32'},
      {name='end_time', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='def', type='uint32'},
      {name='eqms', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='type', type='uint32'}
      }},
      {name='artifacts', type='array', fields={
          {name='artifact_pos', type='uint8'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }},
      {name='holy_eqm', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }}
      }},
      {name='dower_skill', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [23117] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='dun_id', type='uint32'}
   },
   [23118] = {
      {name='buffs', type='array', fields={
          {name='buff_id', type='uint32'}
      }}
   },
   [23119] = {
      {name='partners', type='array', fields={
          {name='flag', type='uint8'},
          {name='partner_id', type='uint32'},
          {name='hp_per', type='uint8'}
      }}
   },
   [23120] = {
      {name='power', type='uint32'}
   },
   [23121] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23122] = {
      {name='formation_type', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='flag', type='uint8'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [23123] = {
   },
   [23200] = {
      {name='recruit_list', type='array', fields={
          {name='group_id', type='uint16'},
          {name='draw_list', type='array', fields={
              {name='times', type='uint8'},
              {name='kv_list', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'},
                  {name='str_val', type='string'}
              }}
          }}
      }},
      {name='is_share', type='uint8'},
      {name='is_day_share', type='uint8'},
      {name='must_five_num', type='uint16'}
   },
   [23201] = {
      {name='group_id', type='uint16'},
      {name='times', type='uint8'},
      {name='flag', type='uint32'},
      {name='rewards', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='partner_bids', type='array', fields={
          {name='partner_bid', type='uint32'},
          {name='init_star', type='uint8'}
      }},
      {name='partner_chips', type='array', fields={
          {name='partner_bid', type='uint32'},
          {name='chip_bid', type='uint32'},
          {name='chip_num', type='uint32'}
      }},
      {name='must_five_num', type='uint16'}
   },
   [23202] = {
      {name='group_id', type='uint16'},
      {name='free_cd_end', type='uint32'},
      {name='free_times', type='uint8'}
   },
   [23203] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='is_share', type='uint8'},
      {name='is_day_share', type='uint8'}
   },
   [23204] = {
      {name='recruit_group', type='array', fields={
          {name='group_id', type='uint16'},
          {name='draw_list', type='array', fields={
              {name='times', type='uint8'},
              {name='kv_list', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'},
                  {name='str_val', type='string'}
              }}
          }}
      }}
   },
   [23210] = {
      {name='fals', type='uint8'},
      {name='end_time', type='uint32'},
      {name='rewards', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [23211] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [23212] = {
   },
   [23213] = {
      {name='group_id', type='uint16'},
      {name='rewards', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [23214] = {
      {name='partner_id', type='uint32'},
      {name='new_partner_bid', type='uint32'},
      {name='partner_ids', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [23215] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [23216] = {
      {name='camp_id', type='uint32'},
      {name='free_time', type='uint32'},
      {name='times', type='uint32'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='item_id', type='uint32'},
      {name='item_num', type='uint32'},
      {name='must_count', type='uint16'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [23217] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23218] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23219] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23220] = {
      {name='camp_id', type='uint32'},
      {name='free_time', type='uint32'},
      {name='times', type='uint32'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='item_id', type='uint32'},
      {name='item_num', type='uint32'},
      {name='must_count', type='uint16'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [23221] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23222] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23230] = {
      {name='camp_id', type='uint32'},
      {name='free_time', type='uint32'},
      {name='times', type='uint32'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='item_id', type='uint32'},
      {name='item_num', type='uint32'},
      {name='must_count', type='uint16'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'}
      }},
      {name='lucky_bid', type='uint32'}
   },
   [23231] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23232] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='award_id', type='uint32'},
      {name='self_award_id', type='uint32'}
   },
   [23233] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23234] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23235] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23300] = {
      {name='base_id', type='uint32'},
      {name='honor', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [23301] = {
      {name='base_id', type='uint32'}
   },
   [23302] = {
      {name='honor', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [23303] = {
      {name='honor', type='array', fields={
          {name='base_id', type='uint32'},
          {name='expire_time', type='uint32'}
      }}
   },
   [23400] = {
      {name='gifts', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'}
      }}
   },
   [23402] = {
      {name='code', type='uint8'}
   },
   [23403] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [23500] = {
      {name='catalg', type='uint32'},
      {name='goods', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='cur_price', type='uint32'},
          {name='margin', type='uint32'}
      }}
   },
   [23501] = {
      {name='flag', type='uint8'}
   },
   [23502] = {
      {name='flag', type='uint8'}
   },
   [23504] = {
   },
   [23505] = {
      {name='type', type='uint8'},
      {name='id', type='uint8'},
      {name='status', type='uint8'},
      {name='num', type='uint8'}
   },
   [23506] = {
      {name='cell_id', type='uint8'},
      {name='flag', type='uint8'}
   },
   [23507] = {
      {name='free_ids', type='array', fields={
          {name='cell_id', type='uint8'}
      }},
      {name='cells', type='array', fields={
          {name='cell_id', type='uint8'},
          {name='item_base_id', type='uint32'},
          {name='num', type='uint8'},
          {name='price', type='uint32'},
          {name='expiry', type='uint32'},
          {name='item_attrs', type='array', fields={
              {name='attr', type='uint8'},
              {name='value', type='uint32'}
          }},
          {name='status', type='uint8'}
      }}
   },
   [23508] = {
      {name='item_base_id', type='uint32'},
      {name='price', type='uint32'}
   },
   [23509] = {
      {name='refresh_time', type='uint32'},
      {name='data', type='array', fields={
          {name='type', type='uint8'},
          {name='goods', type='array', fields={
              {name='id', type='uint8'},
              {name='item_base_id', type='uint32'},
              {name='num', type='uint8'},
              {name='price', type='uint32'},
              {name='status', type='uint8'},
              {name='item_attrs', type='array', fields={
                  {name='attr', type='uint8'},
                  {name='value', type='uint32'}
              }}
          }}
      }}
   },
   [23511] = {
      {name='cell_id', type='uint8'},
      {name='flag', type='uint8'}
   },
   [23512] = {
      {name='cell_id', type='uint8'},
      {name='flag', type='uint8'}
   },
   [23513] = {
   },
   [23514] = {
   },
   [23516] = {
      {name='market_price', type='array', fields={
          {name='source', type='uint8'},
          {name='base_id', type='uint32'},
          {name='assets', type='uint32'},
          {name='price', type='uint32'}
      }}
   },
   [23518] = {
      {name='goods', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='cur_price', type='uint32'},
          {name='margin', type='uint32'}
      }}
   },
   [23519] = {
   },
   [23520] = {
      {name='limit_data', type='array', fields={
          {name='item_id', type='uint32'},
          {name='count', type='uint32'}
      }}
   },
   [23601] = {
      {name='reward', type='uint8'},
      {name='process', type='uint32'},
      {name='double', type='uint8'},
      {name='count', type='uint32'}
   },
   [23602] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [23603] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [23604] = {
      {name='ext_reward', type='array', fields={
          {name='type', type='uint8'},
          {name='rate', type='uint32'}
      }}
   },
   [23606] = {
      {name='ref_time', type='uint32'},
      {name='camp_type', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint8'},
          {name='price', type='uint16'},
          {name='gain', type='uint32'},
          {name='num', type='uint8'},
          {name='max', type='uint8'}
      }}
   },
   [23607] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [23700] = {
      {name='career', type='uint8'},
      {name='group_id', type='uint32'},
      {name='skill_ids', type='array', fields={
          {name='skill_id', type='uint32'}
      }},
      {name='group_ids', type='array', fields={
          {name='group_id', type='uint32'}
      }}
   },
   [23701] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='career', type='uint8'},
      {name='skill_id', type='uint32'}
   },
   [23702] = {
      {name='career', type='uint8'},
      {name='group_id', type='uint32'}
   },
   [23703] = {
      {name='outline', type='array', fields={
          {name='career', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [23704] = {
      {name='is_first', type='uint8'},
      {name='gold', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [23705] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='career', type='uint8'}
   },
   [23706] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='career', type='uint8'}
   },
   [23707] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='career', type='uint8'}
   },
   [23708] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='career', type='uint8'}
   },
   [23709] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='career', type='uint8'}
   },
   [23710] = {
      {name='attr_formation', type='array', fields={
          {name='id', type='uint32'},
          {name='lev', type='uint32'}
      }},
      {name='skill_id', type='uint32'},
      {name='skill_lev', type='uint32'},
      {name='career', type='uint8'},
      {name='is_first', type='uint8'}
   },
   [23711] = {
      {name='guild_skill_break_group', type='array', fields={
          {name='career', type='uint8'},
          {name='attr_formation', type='array', fields={
              {name='id', type='uint32'},
              {name='lev', type='uint32'}
          }},
          {name='skill_id', type='uint32'},
          {name='skill_lev', type='uint32'}
      }},
      {name='is_first', type='uint8'}
   },
   [23800] = {
      {name='order_list', type='array', fields={
          {name='order_id', type='uint32'},
          {name='order_bid', type='uint32'},
          {name='status', type='uint8'},
          {name='end_time', type='uint32'},
          {name='assign_ids', type='array', fields={
              {name='partner_id', type='uint32'}
          }}
      }},
      {name='free_times', type='uint8'},
      {name='coin_times', type='uint32'}
   },
   [23801] = {
      {name='order_id', type='uint32'},
      {name='order_bid', type='uint32'},
      {name='status', type='uint8'},
      {name='end_time', type='uint32'},
      {name='assign_ids', type='array', fields={
          {name='partner_id', type='uint32'}
      }}
   },
   [23802] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23803] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='order_id', type='uint32'}
   },
   [23804] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [23805] = {
      {name='flag', type='uint8'}
   },
   [23806] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='order_list', type='array', fields={
          {name='order_id', type='uint32'}
      }}
   },
   [23900] = {
      {name='type', type='uint8'},
      {name='select_type', type='uint8'},
      {name='next_type', type='uint8'},
      {name='next_time', type='uint32'},
      {name='max_round', type='uint16'},
      {name='current_round', type='uint16'},
      {name='day_pass_round', type='uint16'},
      {name='my_idx', type='uint16'},
      {name='rank_list', type='array', fields={
          {name='idx', type='uint8'},
          {name='name', type='string'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='val', type='uint32'}
      }},
      {name='new_max_round', type='uint16'},
      {name='new_current_round', type='uint16'},
      {name='new_day_pass_round', type='uint16'},
      {name='new_my_idx', type='uint16'},
      {name='new_rank_list', type='array', fields={
          {name='idx', type='uint8'},
          {name='name', type='string'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='val', type='uint32'}
      }},
      {name='is_employ', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='power', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='is_appoint', type='uint8'},
      {name='is_reward', type='uint8'}
   },
   [23901] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [23902] = {
      {name='round', type='uint16'},
      {name='max_round', type='uint16'},
      {name='buff_list', type='array', fields={
          {name='id', type='uint32'},
          {name='group_id', type='uint16'},
          {name='count', type='uint16'}
      }},
      {name='rest_round', type='uint16'},
      {name='max_reward_round', type='uint16'},
      {name='reward_flag', type='uint8'},
      {name='acc_reward', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='id', type='uint32'},
      {name='status', type='uint8'},
      {name='type', type='uint8'}
   },
   [23903] = {
      {name='id', type='uint32'},
      {name='status', type='uint8'},
      {name='max_id', type='uint32'},
      {name='rewarded', type='array', fields={
          {name='id', type='uint16'}
      }},
      {name='type', type='uint8'}
   },
   [23904] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'}
   },
   [23905] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='power', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [23906] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='power', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [23907] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='power', type='uint32'},
          {name='is_return', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [23908] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [23909] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [23910] = {
      {name='is_select', type='uint8'},
      {name='list', type='array', fields={
          {name='group_id', type='uint8'},
          {name='buff_id', type='uint16'}
      }},
      {name='partner', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='quality', type='uint8'},
          {name='hp_per', type='uint8'},
          {name='use_skin', type='uint32'},
          {name='resonate_lev', type='uint32'}
      }},
      {name='formation_type', type='uint8'},
      {name='formation_lev', type='uint8'},
      {name='round', type='uint16'}
   },
   [23911] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [23912] = {
      {name='flag', type='uint8'}
   },
   [23913] = {
      {name='my_idx', type='uint16'},
      {name='rank_list', type='array', fields={
          {name='idx', type='uint8'},
          {name='name', type='string'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='val', type='uint32'}
      }}
   },
   [24000] = {
      {name='plunders', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='quality', type='uint8'},
          {name='end_time', type='uint32'},
          {name='plunder_lists', type='array', fields={
              {name='rid', type='uint32'},
              {name='srv_id', type='string'}
          }}
      }}
   },
   [24001] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24002] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24003] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24004] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24005] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='plunders', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='quality', type='uint8'},
          {name='end_time', type='uint32'}
      }}
   },
   [24006] = {
      {name='status', type='uint8'},
      {name='quality', type='uint8'},
      {name='end_time', type='uint32'},
      {name='plunder_count', type='uint32'},
      {name='datas', type='array', fields={
          {name='id', type='uint8'},
          {name='val', type='uint8'}
      }}
   },
   [24010] = {
      {name='quality', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='gid', type='uint32'},
      {name='gsrv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='face', type='uint32'},
      {name='power', type='uint32'},
      {name='guild_name', type='string'},
      {name='formation_type', type='uint8'},
      {name='formation_lev', type='uint8'},
      {name='p_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'}
      }}
   },
   [24011] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24012] = {
      {name='result', type='uint8'},
      {name='item_rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [24013] = {
      {name='type', type='uint8'},
      {name='logs', type='array', fields={
          {name='id', type='uint32'},
          {name='quality', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='guild_name', type='string'},
          {name='lev', type='uint8'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='ret', type='uint8'},
          {name='atk_ret', type='uint8'},
          {name='atk_count', type='uint8'},
          {name='time', type='uint32'},
          {name='help_count', type='uint32'},
          {name='help_time', type='uint32'},
          {name='items', type='array', fields={
              {name='bid', type='uint32'},
              {name='num', type='uint32'}
          }},
          {name='replay_id', type='uint32'}
      }}
   },
   [24014] = {
      {name='quality', type='uint8'},
      {name='id', type='uint32'},
      {name='type', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint8'},
      {name='face', type='uint32'},
      {name='avatar_id', type='uint32'},
      {name='power', type='uint32'},
      {name='guild_name', type='string'},
      {name='formation_type', type='uint8'},
      {name='formation_lev', type='uint8'},
      {name='p_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint8'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'}
      }}
   },
   [24015] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24017] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24018] = {
      {name='id', type='uint32'},
      {name='quality', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='guild_name', type='string'},
      {name='lev', type='uint8'},
      {name='sex', type='uint8'},
      {name='face', type='uint32'},
      {name='power', type='uint32'},
      {name='avatar_id', type='uint32'},
      {name='ret', type='uint8'},
      {name='atk_ret', type='uint8'},
      {name='atk_count', type='uint8'},
      {name='time', type='uint32'},
      {name='help_count', type='uint32'},
      {name='help_time', type='uint32'},
      {name='items', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='replay_id', type='uint32'}
   },
   [24019] = {
      {name='plunders', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='gid', type='uint32'},
          {name='gsrv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='quality', type='uint8'},
          {name='end_time', type='uint32'}
      }}
   },
   [24020] = {
      {name='code', type='uint8'}
   },
   [24100] = {
      {name='hallows', type='array', fields={
          {name='id', type='uint32'},
          {name='step', type='uint32'},
          {name='lucky', type='uint32'},
          {name='lucky_endtime', type='uint32'},
          {name='seal', type='uint32'},
          {name='add_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='skill', type='array', fields={
              {name='lev', type='uint32'},
              {name='skill_bid', type='uint32'}
          }},
          {name='look_id', type='uint32'},
          {name='refine_lev', type='uint32'}
      }}
   },
   [24101] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [24103] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='hallows_id', type='uint32'}
   },
   [24104] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [24107] = {
      {name='id', type='uint32'},
      {name='step', type='uint32'},
      {name='lucky', type='uint32'},
      {name='lucky_endtime', type='uint32'},
      {name='seal', type='uint32'},
      {name='add_attr', type='array', fields={
          {name='attr_id', type='uint32'},
          {name='attr_val', type='uint32'}
      }},
      {name='skill', type='array', fields={
          {name='lev', type='uint32'},
          {name='skill_bid', type='uint32'}
      }},
      {name='look_id', type='uint32'},
      {name='refine_lev', type='uint32'}
   },
   [24108] = {
      {name='id', type='uint32'},
      {name='step', type='uint32'},
      {name='lucky', type='uint32'},
      {name='lucky_endtime', type='uint32'},
      {name='seal', type='uint32'},
      {name='add_attr', type='array', fields={
          {name='attr_id', type='uint32'},
          {name='attr_val', type='uint32'}
      }},
      {name='skill', type='array', fields={
          {name='lev', type='uint32'},
          {name='skill_bid', type='uint32'}
      }},
      {name='look_id', type='uint32'},
      {name='refine_lev', type='uint32'}
   },
   [24120] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [24121] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [24122] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24123] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24124] = {
      {name='is_first', type='uint8'}
   },
   [24125] = {
      {name='hallows_looks', type='array', fields={
          {name='id', type='uint32'},
          {name='endtime', type='uint32'},
          {name='eqm_hallows', type='uint32'}
      }}
   },
   [24126] = {
      {name='id', type='uint32'},
      {name='endtime', type='uint32'},
      {name='eqm_hallows', type='uint32'}
   },
   [24127] = {
      {name='id', type='uint32'},
      {name='endtime', type='uint32'},
      {name='eqm_hallows', type='uint32'}
   },
   [24128] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [24129] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [24130] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24131] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24132] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24133] = {
      {name='id', type='uint32'}
   },
   [24135] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='hallows_id', type='uint32'},
      {name='refine_lev', type='uint32'}
   },
   [24136] = {
      {name='hallows', type='array', fields={
          {name='id', type='uint32'},
          {name='step', type='uint32'},
          {name='add_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='skill', type='array', fields={
              {name='lev', type='uint32'},
              {name='skill_bid', type='uint32'}
          }},
          {name='look_id', type='uint32'},
          {name='refine_lev', type='uint32'}
      }}
   },
   [24200] = {
      {name='count', type='uint32'},
      {name='result', type='uint8'},
      {name='ranks', type='array', fields={
          {name='rank', type='uint32'},
          {name='name', type='string'}
      }},
      {name='gname1', type='string'},
      {name='hp1', type='uint16'},
      {name='buff_lev1', type='uint16'},
      {name='gname2', type='string'},
      {name='g_id', type='uint32'},
      {name='g_sid', type='string'},
      {name='hp2', type='uint16'},
      {name='defense', type='array', fields={
          {name='pos', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='hp', type='uint16'},
          {name='hp_max', type='uint16'},
          {name='relic_def_count', type='uint16'},
          {name='status', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [24201] = {
      {name='pos', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint16'},
      {name='face', type='uint32'},
      {name='power', type='uint32'},
      {name='formation_type', type='uint16'},
      {name='formation_lev', type='uint16'},
      {name='hp', type='uint16'},
      {name='hp_max', type='uint16'},
      {name='def_count', type='uint16'},
      {name='relic_def_count', type='uint16'},
      {name='defense', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [24202] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'}
   },
   [24203] = {
      {name='result', type='uint8'},
      {name='timer', type='uint32'},
      {name='item_rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='use_skin', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='replay_id', type='uint32'}
   },
   [24204] = {
      {name='status', type='uint8'},
      {name='flag', type='uint8'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'}
   },
   [24205] = {
      {name='match_info', type='array', fields={
          {name='g_id1', type='uint32'},
          {name='g_sid1', type='string'},
          {name='srv_name1', type='string'},
          {name='guild_name1', type='string'},
          {name='rank1', type='uint32'},
          {name='g_id2', type='uint32'},
          {name='g_sid2', type='string'},
          {name='srv_name2', type='string'},
          {name='guild_name2', type='string'},
          {name='rank2', type='uint32'},
          {name='status', type='uint8'},
          {name='g_id', type='uint32'},
          {name='g_sid', type='string'}
      }}
   },
   [24206] = {
      {name='flag', type='uint8'},
      {name='defense', type='array', fields={
          {name='pos', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='hp', type='uint16'},
          {name='hp_max', type='uint16'},
          {name='relic_def_count', type='uint16'},
          {name='status', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [24207] = {
      {name='ranks', type='array', fields={
          {name='rank', type='uint32'},
          {name='name', type='string'}
      }},
      {name='hp', type='uint16'},
      {name='buff_lev', type='uint16'},
      {name='hp2', type='uint16'}
   },
   [24208] = {
      {name='hp', type='uint16'},
      {name='defense', type='array', fields={
          {name='pos', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='hp', type='uint16'},
          {name='hp_max', type='uint16'},
          {name='relic_def_count', type='uint16'},
          {name='status', type='uint8'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='avg_power', type='uint32'}
   },
   [24209] = {
      {name='power', type='uint32'},
      {name='formation_type', type='uint32'},
      {name='formation_lev', type='uint32'},
      {name='defense', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint8'},
          {name='resonate_lev', type='uint32'}
      }},
      {name='guild_war_role_log', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='time', type='uint32'},
          {name='repaly_id', type='uint32'},
          {name='hp', type='uint16'},
          {name='result', type='uint8'},
          {name='formation_type', type='uint32'},
          {name='formation_lev', type='uint32'},
          {name='defense', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='use_skin', type='uint32'},
              {name='end_time', type='uint8'},
              {name='resonate_lev', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [24210] = {
   },
   [24212] = {
      {name='guild_war_log', type='array', fields={
          {name='flag1', type='uint8'},
          {name='flag2', type='uint8'},
          {name='time', type='uint32'},
          {name='rid1', type='uint32'},
          {name='srv_id1', type='string'},
          {name='name1', type='string'},
          {name='rid2', type='uint32'},
          {name='srv_id2', type='string'},
          {name='name2', type='string'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='gname', type='string'},
          {name='int_args', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }},
          {name='str_args', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='string'}
          }}
      }}
   },
   [24213] = {
      {name='ranks', type='array', fields={
          {name='rank', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='face', type='uint32'},
          {name='lev', type='uint32'},
          {name='name', type='string'},
          {name='star', type='uint32'},
          {name='war_score', type='uint32'},
          {name='look_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [24214] = {
      {name='result', type='uint8'}
   },
   [24220] = {
      {name='result', type='uint8'},
      {name='end_time', type='uint32'},
      {name='status', type='uint8'},
      {name='guild_war_box', type='array', fields={
          {name='order', type='uint16'},
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'}
      }}
   },
   [24221] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24223] = {
      {name='order', type='uint16'},
      {name='rid', type='uint32'},
      {name='sid', type='string'},
      {name='name', type='string'},
      {name='item_id', type='uint32'},
      {name='item_num', type='uint32'}
   },
   [24300] = {
      {name='rank', type='uint16'},
      {name='best_rank', type='uint16'},
      {name='can_combat_num', type='uint8'},
      {name='buy_combat_num', type='uint8'},
      {name='ref_time', type='int32'},
      {name='combat_time', type='int32'}
   },
   [24301] = {
      {name='f_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='idx', type='uint8'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='rank', type='uint32'},
          {name='look', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='type', type='uint8'}
   },
   [24302] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint16'},
      {name='vip_lev', type='uint8'},
      {name='face', type='uint32'},
      {name='sex', type='uint8'},
      {name='power', type='uint32'},
      {name='rank', type='uint32'},
      {name='gname', type='string'},
      {name='avatar_id', type='uint32'},
      {name='formation_type', type='uint8'},
      {name='formation_lev', type='uint8'},
      {name='p_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='is_robot', type='uint8'}
      }},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'}
   },
   [24303] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24304] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24305] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24306] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24307] = {
      {name='result', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='def_name', type='string'},
      {name='def_lev', type='uint32'},
      {name='def_face', type='uint32'},
      {name='def_face_update_time', type='uint32'},
      {name='def_face_file', type='string'},
      {name='def_change_rank', type='int32'},
      {name='def_rank', type='uint32'},
      {name='is_change_best_rank', type='uint32'},
      {name='atk_change_rank', type='int32'},
      {name='atk_rank', type='uint32'},
      {name='reward', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='replay_id', type='uint32'}
   },
   [24308] = {
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='rank', type='uint32'},
          {name='lookid', type='uint32'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [24309] = {
      {name='rank', type='uint16'},
      {name='best_rank', type='uint16'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='power', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [24310] = {
      {name='replay_srv_id', type='string'},
      {name='log_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='power', type='uint32'},
          {name='type', type='uint8'},
          {name='ret', type='uint8'},
          {name='rank_type', type='uint8'},
          {name='rank', type='uint32'},
          {name='replay_id', type='uint32'},
          {name='time', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [24311] = {
      {name='replay_srv_id', type='string'},
      {name='log_list', type='array', fields={
          {name='atk_rid', type='uint32'},
          {name='atk_srv_id', type='string'},
          {name='atk_name', type='string'},
          {name='atk_face', type='uint32'},
          {name='atk_rank', type='uint32'},
          {name='def_rid', type='uint32'},
          {name='def_srv_id', type='string'},
          {name='def_name', type='string'},
          {name='def_face', type='uint32'},
          {name='def_rank', type='uint32'},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='time', type='uint32'},
          {name='atk_face_update_time', type='uint32'},
          {name='atk_face_file', type='string'},
          {name='def_face_update_time', type='uint32'},
          {name='def_face_file', type='string'}
      }}
   },
   [24312] = {
      {name='code', type='uint8'}
   },
   [24313] = {
      {name='code', type='uint8'}
   },
   [24314] = {
      {name='code', type='uint8'}
   },
   [24315] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24316] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24317] = {
      {name='code', type='uint8'}
   },
   [24318] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [24400] = {
      {name='guard_id', type='uint32'},
      {name='difficulty', type='uint8'},
      {name='max_difficulty', type='uint8'},
      {name='reward', type='array', fields={
          {name='reward_id', type='uint32'}
      }},
      {name='rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [24401] = {
      {name='id', type='uint8'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='face', type='uint32'},
      {name='lev', type='uint8'},
      {name='power', type='uint32'},
      {name='guards', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='hp_per', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='is_holiday', type='uint8'},
      {name='status', type='uint8'}
   },
   [24402] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [24403] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24405] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='power', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [24406] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='power', type='uint32'},
          {name='is_employ', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [24407] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [24408] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24409] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='power', type='uint32'},
          {name='is_used', type='uint8'},
          {name='hp_per', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='p_list', type='array', fields={
          {name='id', type='uint32'},
          {name='hp_per', type='uint8'}
      }}
   },
   [24410] = {
      {name='is_show', type='uint8'}
   },
   [24411] = {
      {name='is_show', type='uint8'}
   },
   [24412] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24413] = {
   },
   [24414] = {
      {name='guard_id', type='uint32'},
      {name='floor_id', type='uint32'},
      {name='rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [24415] = {
      {name='replay_infos', type='array', fields={
          {name='id', type='uint32'},
          {name='round', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='guard_id', type='uint32'},
          {name='difficulty', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint32'},
          {name='a_end_hp', type='uint8'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint32'},
          {name='b_end_hp', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }}
      }}
   },
   [24500] = {
      {name='list', type='array', fields={
          {name='id', type='uint8'},
          {name='status', type='uint8'},
          {name='expire_time', type='uint32'}
      }}
   },
   [24501] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24502] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'},
          {name='expire_time', type='uint32'}
      }}
   },
   [24600] = {
      {name='status', type='uint8'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='flag', type='uint8'}
   },
   [24601] = {
      {name='id', type='uint32'},
      {name='title', type='string'},
      {name='memo', type='string'},
      {name='rewards', type='array', fields={
          {name='bid', type='uint32'},
          {name='bind', type='uint8'},
          {name='num', type='uint32'}
      }}
   },
   [24602] = {
      {name='questionnaire_list', type='array', fields={
          {name='id', type='uint32'},
          {name='title', type='string'},
          {name='sort', type='uint16'},
          {name='topic_type', type='uint8'},
          {name='specific_type', type='uint8'},
          {name='must', type='uint8'},
          {name='jump', type='uint8'},
          {name='topic', type='uint32'},
          {name='option', type='string'},
          {name='option_list', type='string'}
      }}
   },
   [24603] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24604] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24700] = {
      {name='ids', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'},
          {name='show', type='uint8'}
      }}
   },
   [24701] = {
      {name='id', type='uint32'},
      {name='current_day', type='uint16'},
      {name='group_id', type='uint16'},
      {name='endtime', type='uint32'},
      {name='status', type='uint8'}
   },
   [24702] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24703] = {
      {name='ids', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [24801] = {
      {name='all_num', type='uint32'},
      {name='award_list', type='array', fields={
          {name='id', type='uint8'},
          {name='flag', type='uint8'}
      }}
   },
   [24802] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='rand_list', type='array', fields={
          {name='rand_id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [24803] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [24804] = {
      {name='lev', type='uint32'},
      {name='exp', type='uint32'},
      {name='camp_id', type='uint32'},
      {name='group_id', type='uint32'},
      {name='combat_num', type='uint16'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='show_list', type='array', fields={
          {name='show_id', type='uint8'},
          {name='num', type='uint32'}
      }},
      {name='make_list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [24805] = {
      {name='lev', type='uint32'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [24806] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [24807] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [24808] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [24809] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='combat_num', type='uint16'}
   },
   [24810] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }},
      {name='camp_id', type='uint32'}
   },
   [24811] = {
      {name='id', type='uint32'},
      {name='finish', type='uint8'},
      {name='end_time', type='uint32'},
      {name='finish_time', type='uint32'},
      {name='progress', type='array', fields={
          {name='id', type='uint16'},
          {name='finish', type='uint8'},
          {name='target', type='uint32'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }}
   },
   [24812] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [24813] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }},
      {name='camp_id', type='uint32'}
   },
   [24814] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [24815] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }},
      {name='camp_id', type='uint32'}
   },
   [24816] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [24817] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }},
      {name='camp_id', type='uint32'}
   },
   [24818] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [24900] = {
      {name='lev', type='uint32'},
      {name='score', type='int32'},
      {name='day_combat_count', type='uint32'},
      {name='day_buy_count', type='uint32'},
      {name='match_cd_time', type='uint32'},
      {name='rank', type='uint16'},
      {name='is_king', type='uint8'},
      {name='promoted_info', type='array', fields={
          {name='count', type='uint8'},
          {name='flag', type='uint8'}
      }},
      {name='state', type='uint8'},
      {name='period', type='uint32'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='state_time', type='uint32'},
      {name='lev_reward', type='array', fields={
          {name='lev', type='uint8'},
          {name='flag', type='uint8'}
      }},
      {name='zone_id', type='int32'},
      {name='day_max_buy_count', type='uint32'},
      {name='is_skip', type='uint32'},
      {name='rmb_status', type='uint8'}
   },
   [24901] = {
      {name='day_combat_count', type='uint32'},
      {name='match_cd_time', type='uint32'},
      {name='to_combat_time', type='uint32'},
      {name='is_match', type='uint8'},
      {name='rand_list', type='array', fields={
          {name='end_time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='power', type='uint32'},
          {name='lev', type='uint32'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='look_id', type='uint32'},
          {name='score', type='uint32'},
          {name='elite_lev', type='uint32'},
          {name='defense', type='array', fields={
              {name='type', type='uint8'},
              {name='defense_info', type='array', fields={
                  {name='order', type='uint8'},
                  {name='formation_type', type='uint32'},
                  {name='partner_infos', type='array', fields={
                      {name='pos', type='uint8'},
                      {name='bid', type='uint32'},
                      {name='lev', type='uint16'},
                      {name='star', type='uint8'},
                      {name='power', type='uint32'},
                      {name='extra', type='array', fields={
                          {name='key', type='uint32'},
                          {name='val', type='uint32'}
                      }}
                  }}
              }}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [24902] = {
   },
   [24903] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24904] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='day_combat_count', type='uint32'},
      {name='day_buy_count', type='uint32'}
   },
   [24905] = {
      {name='state', type='uint8'},
      {name='end_time', type='uint32'}
   },
   [24906] = {
      {name='result', type='uint8'},
      {name='win_count', type='uint32'},
      {name='lose_count', type='uint32'},
      {name='combat_type', type='uint32'},
      {name='promoted_info', type='array', fields={
          {name='count', type='uint8'},
          {name='flag', type='uint8'}
      }},
      {name='elite_lev', type='int32'},
      {name='new_elite_lev', type='int32'},
      {name='big_score', type='int32'},
      {name='score', type='int32'},
      {name='end_score', type='int32'},
      {name='add_score', type='int32'},
      {name='awards', type='array', fields={
          {name='item_id', type='uint32'},
          {name='item_num', type='uint32'}
      }},
      {name='all_hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='a_round', type='uint8'},
          {name='b_round', type='uint8'},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }},
          {name='replay_id', type='uint32'}
      }},
      {name='target_role_name', type='string'}
   },
   [24910] = {
      {name='zone_info', type='array', fields={
          {name='period', type='uint32'},
          {name='max_zone_id', type='uint32'}
      }}
   },
   [24911] = {
      {name='rank', type='uint32'},
      {name='elite_lev', type='uint32'},
      {name='score', type='uint32'},
      {name='period', type='uint32'},
      {name='arena_elite_rank', type='array', fields={
          {name='rank', type='uint16'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='score', type='uint32'},
          {name='elite_lev', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='look_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='zone_id', type='uint32'},
      {name='max_zone_id', type='uint32'}
   },
   [24915] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='lev_reward', type='array', fields={
          {name='lev', type='uint8'},
          {name='flag', type='uint8'}
      }}
   },
   [24920] = {
      {name='type', type='uint8'},
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'}
      }}
   },
   [24921] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24930] = {
      {name='type', type='uint8'},
      {name='arena_elite_log', type='array', fields={
          {name='id', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='atk_name', type='string'},
          {name='atk_face', type='uint32'},
          {name='atk_lev', type='uint32'},
          {name='atk_rank', type='uint32'},
          {name='atk_elite_lev', type='uint32'},
          {name='def_rid', type='uint32'},
          {name='def_srv_id', type='string'},
          {name='def_name', type='string'},
          {name='def_face', type='uint32'},
          {name='def_lev', type='uint32'},
          {name='def_rank', type='uint32'},
          {name='def_elite_lev', type='uint32'},
          {name='ret', type='uint8'},
          {name='win_count', type='uint8'},
          {name='lose_count', type='uint8'},
          {name='combat_type', type='uint8'},
          {name='time', type='uint32'},
          {name='atk_face_update_time', type='uint32'},
          {name='atk_face_file', type='string'},
          {name='def_face_update_time', type='uint32'},
          {name='def_face_file', type='string'}
      }}
   },
   [24931] = {
      {name='type', type='uint8'},
      {name='id', type='uint32'},
      {name='arena_replay_infos', type='array', fields={
          {name='order', type='uint8'},
          {name='id', type='uint32'},
          {name='round', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint32'},
          {name='a_order', type='uint8'},
          {name='a_end_hp', type='uint8'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint32'},
          {name='b_order', type='uint8'},
          {name='b_end_hp', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='a_add_power', type='uint32'},
          {name='b_add_power', type='uint32'}
      }}
   },
   [24940] = {
      {name='best_mvp', type='uint32'},
      {name='my_score', type='uint32'},
      {name='my_elite_lev', type='uint32'},
      {name='period', type='uint32'},
      {name='max_lev', type='uint16'},
      {name='max_score', type='uint32'},
      {name='combat_win_count1', type='uint32'},
      {name='combat_all_count1', type='uint32'},
      {name='combat_win_count2', type='uint8'},
      {name='combat_all_count2', type='uint32'},
      {name='max_dps', type='uint32'},
      {name='winning_streak', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint32'},
      {name='sex', type='uint32'},
      {name='g_rid', type='uint32'},
      {name='g_srv_id', type='string'},
      {name='gname', type='string'},
      {name='power', type='array', fields={
          {name='order', type='uint8'},
          {name='power', type='uint32'}
      }},
      {name='face', type='uint32'},
      {name='score', type='uint32'},
      {name='elite_lev', type='uint32'},
      {name='avatar_id', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='log_zone_id', type='uint32'},
      {name='log_rank', type='uint32'},
      {name='use_skin', type='uint32'}
   },
   [24941] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24942] = {
      {name='id', type='uint32'},
      {name='share_srv_id', type='string'},
      {name='best_mvp', type='uint32'},
      {name='my_score', type='uint32'},
      {name='my_elite_lev', type='uint32'},
      {name='period', type='uint32'},
      {name='max_lev', type='uint16'},
      {name='max_score', type='uint32'},
      {name='combat_win_count1', type='uint32'},
      {name='combat_all_count1', type='uint32'},
      {name='combat_win_count2', type='uint8'},
      {name='combat_all_count2', type='uint32'},
      {name='max_dps', type='uint32'},
      {name='winning_streak', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint32'},
      {name='sex', type='uint32'},
      {name='g_rid', type='uint32'},
      {name='g_srv_id', type='string'},
      {name='gname', type='string'},
      {name='power', type='array', fields={
          {name='order', type='uint8'},
          {name='power', type='uint32'}
      }},
      {name='face', type='uint32'},
      {name='score', type='uint32'},
      {name='elite_lev', type='uint32'},
      {name='avatar_id', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='log_zone_id', type='uint32'},
      {name='log_rank', type='uint32'},
      {name='use_skin', type='uint32'}
   },
   [24945] = {
      {name='manifesto', type='array', fields={
          {name='order', type='uint8'},
          {name='manifesto_id', type='uint32'}
      }}
   },
   [24946] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [24950] = {
   },
   [24951] = {
   },
   [24952] = {
      {name='period', type='uint16'},
      {name='cur_day', type='uint32'},
      {name='end_time', type='uint32'},
      {name='lev', type='uint32'},
      {name='rmb_status', type='uint8'},
      {name='win_count', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='award_status', type='uint8'},
          {name='rmb_award_status', type='uint8'}
      }}
   },
   [24953] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [24954] = {
      {name='flag', type='uint8'}
   },
   [24955] = {
      {name='is_pop', type='uint8'},
      {name='cur_day', type='uint32'}
   },
   [25000] = {
      {name='day', type='uint8'},
      {name='num', type='uint8'},
      {name='buy_num', type='uint8'},
      {name='refresh_time', type='uint32'},
      {name='pr_buy_num', type='uint32'},
      {name='list', type='array', fields={
          {name='type', type='uint8'},
          {name='group', type='uint16'},
          {name='boss_id', type='uint32'},
          {name='endtime', type='uint32'}
      }}
   },
   [25001] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25002] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25003] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25004] = {
      {name='num', type='uint8'},
      {name='buy_num', type='uint8'},
      {name='pr_buy_num', type='uint32'},
      {name='refresh_time', type='uint32'}
   },
   [25005] = {
      {name='type', type='uint8'},
      {name='group', type='uint16'},
      {name='boss_id', type='uint32'}
   },
   [25100] = {
      {name='state', type='uint8'},
      {name='quests', type='array', fields={
          {name='id', type='uint32'},
          {name='val', type='uint32'},
          {name='status', type='uint8'}
      }},
      {name='end_time', type='uint32'}
   },
   [25101] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25200] = {
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'},
      {name='max_dun_id', type='uint32'},
      {name='chapter_info', type='array', fields={
          {name='id', type='uint32'},
          {name='all_star', type='uint8'},
          {name='award_info', type='array', fields={
              {name='id', type='uint8'},
              {name='flag', type='uint8'}
          }},
          {name='is_finish', type='uint8'}
      }}
   },
   [25201] = {
      {name='id', type='uint32'},
      {name='all_star', type='uint8'},
      {name='dun_info', type='array', fields={
          {name='id', type='uint32'},
          {name='state', type='uint32'},
          {name='star', type='uint32'},
          {name='star_info', type='array', fields={
              {name='star_id', type='uint8'},
              {name='flag', type='uint8'}
          }}
      }}
   },
   [25203] = {
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'},
      {name='max_dun_id', type='uint32'},
      {name='chapter_info', type='array', fields={
          {name='id', type='uint32'},
          {name='all_star', type='uint8'},
          {name='award_info', type='array', fields={
              {name='id', type='uint8'},
              {name='flag', type='uint8'}
          }},
          {name='is_finish', type='uint8'}
      }}
   },
   [25204] = {
      {name='id', type='uint32'},
      {name='dun_info', type='array', fields={
          {name='id', type='uint32'},
          {name='state', type='uint32'},
          {name='star', type='uint32'},
          {name='star_info', type='array', fields={
              {name='star_id', type='uint8'},
              {name='flag', type='uint8'}
          }}
      }}
   },
   [25205] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25206] = {
      {name='result', type='uint8'},
      {name='id', type='uint32'},
      {name='order_id', type='uint32'},
      {name='star_info', type='array', fields={
          {name='id', type='uint32'},
          {name='state', type='uint32'}
      }},
      {name='award', type='array', fields={
          {name='item_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='all_hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='a_round', type='uint8'},
          {name='b_round', type='uint8'},
          {name='target_role_name', type='string'},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }}
      }}
   },
   [25207] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'}
   },
   [25208] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint8'}
   },
   [25210] = {
      {name='type', type='uint8'},
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'}
      }}
   },
   [25211] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25215] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='award_info', type='array', fields={
          {name='id', type='uint8'},
          {name='flag', type='uint8'}
      }}
   },
   [25216] = {
      {name='combat_type', type='uint32'},
      {name='flag', type='uint8'}
   },
   [25217] = {
      {name='group_id', type='uint16'},
      {name='times', type='uint8'},
      {name='recruit_type', type='uint8'},
      {name='rewards', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [25218] = {
      {name='type', type='uint8'},
      {name='group_id', type='uint16'},
      {name='log_list', type='array', fields={
          {name='role_name', type='string'},
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [25219] = {
      {name='recruit_list', type='array', fields={
          {name='group_id', type='uint16'},
          {name='free_times', type='uint8'},
          {name='reset_time', type='uint32'},
          {name='baodi_count', type='uint32'},
          {name='lucky_holy_eqm', type='array', fields={
              {name='pos', type='uint8'},
              {name='lucky_holy_eqm', type='uint32'}
          }},
          {name='all_award_count', type='uint32'},
          {name='do_awards', type='array', fields={
              {name='award_id', type='uint32'}
          }},
          {name='day_count', type='uint32'},
          {name='is_open', type='uint8'}
      }}
   },
   [25220] = {
      {name='num', type='uint32'},
      {name='holy_eqm_set_cell', type='array', fields={
          {name='id', type='uint32'},
          {name='partner_id', type='uint32'},
          {name='name', type='string'},
          {name='list', type='array', fields={
              {name='partner_id', type='uint32'},
              {name='item_id', type='uint32'}
          }}
      }}
   },
   [25221] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25222] = {
      {name='holy_eqm_set_cell', type='array', fields={
          {name='id', type='uint32'},
          {name='partner_id', type='uint32'},
          {name='name', type='string'},
          {name='list', type='array', fields={
              {name='partner_id', type='uint32'},
              {name='item_id', type='uint32'}
          }}
      }}
   },
   [25223] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='num', type='uint32'}
   },
   [25224] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25230] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [25231] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [25232] = {
      {name='score', type='uint32'}
   },
   [25300] = {
      {name='period', type='uint8'},
      {name='cur_day', type='uint32'},
      {name='end_time', type='uint32'},
      {name='lev', type='uint32'},
      {name='exp', type='uint32'},
      {name='rmb_status', type='uint8'},
      {name='exp_status', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='type', type='uint8'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'},
          {name='end_time', type='uint32'}
      }}
   },
   [25301] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='type', type='uint8'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'},
          {name='end_time', type='uint32'}
      }}
   },
   [25302] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25303] = {
      {name='lev', type='uint32'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'},
          {name='status', type='uint8'},
          {name='rmb_status', type='uint8'}
      }}
   },
   [25304] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [25305] = {
      {name='lev', type='uint32'},
      {name='exp', type='uint32'}
   },
   [25306] = {
      {name='rmb_status', type='uint8'},
      {name='exp_status', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [25307] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [25308] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [25309] = {
      {name='is_pop', type='uint8'},
      {name='cur_day', type='uint32'}
   },
   [25400] = {
      {name='order', type='uint8'},
      {name='score', type='uint32'},
      {name='rank', type='uint32'},
      {name='count', type='uint8'}
   },
   [25401] = {
      {name='order', type='uint8'},
      {name='score', type='uint32'},
      {name='rank', type='uint32'},
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'},
      {name='hp_per', type='uint32'},
      {name='award_info', type='array', fields={
          {name='award_id', type='uint32'}
      }}
   },
   [25402] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'}
   },
   [25403] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='award_info', type='array', fields={
          {name='award_id', type='uint32'}
      }}
   },
   [25404] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25405] = {
      {name='result', type='uint8'},
      {name='dps_score', type='uint32'},
      {name='kill_score', type='uint32'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [25410] = {
      {name='round', type='uint8'},
      {name='difficulty', type='uint8'},
      {name='order', type='uint8'},
      {name='order_type', type='uint8'},
      {name='round_combat', type='uint32'},
      {name='round_boss', type='uint32'},
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'},
      {name='endtime', type='uint32'},
      {name='hp_per', type='uint32'},
      {name='status', type='uint8'}
   },
   [25411] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint8'},
      {name='buy_count', type='uint8'}
   },
   [25412] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25413] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25414] = {
      {name='p_list', type='array', fields={
          {name='id', type='uint32'},
          {name='count', type='uint8'}
      }}
   },
   [25500] = {
      {name='period', type='uint8'},
      {name='day_time', type='uint32'},
      {name='week_time', type='uint32'},
      {name='month_time', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='price', type='uint32'},
          {name='charge_id', type='uint32'},
          {name='limit_type', type='uint8'},
          {name='buy_num', type='uint32'},
          {name='limit_num', type='uint32'},
          {name='original_price', type='uint32'},
          {name='res_name', type='uint32'},
          {name='rank', type='uint32'},
          {name='icon', type='uint32'},
          {name='award_list', type='array', fields={
              {name='item_id', type='uint32'},
              {name='item_num', type='uint32'}
          }}
      }}
   },
   [25600] = {
      {name='rank', type='uint16'},
      {name='max_rank', type='uint16'},
      {name='score', type='uint32'},
      {name='can_combat_num', type='uint8'},
      {name='buy_combat_num', type='uint8'},
      {name='ref_time', type='int32'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='is_auto', type='uint8'},
      {name='season_combat_num', type='uint32'}
   },
   [25601] = {
      {name='f_list', type='array', fields={
          {name='idx', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='look', type='uint32'},
          {name='power', type='uint32'},
          {name='score', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='type', type='uint8'}
   },
   [25602] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='lev', type='uint16'},
      {name='face', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='sex', type='uint8'},
      {name='power', type='uint32'},
      {name='score', type='uint32'},
      {name='avatar_id', type='uint32'},
      {name='order_list', type='array', fields={
          {name='order', type='uint8'},
          {name='power', type='uint32'},
          {name='is_hidden', type='uint8'},
          {name='p_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='use_skin', type='uint32'},
              {name='resonate_lev', type='uint32'}
          }}
      }}
   },
   [25603] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25604] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25605] = {
      {name='type', type='uint8'},
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'},
          {name='is_hidden', type='uint8'}
      }}
   },
   [25606] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25607] = {
      {name='had_combat_num', type='uint16'},
      {name='num_list', type='array', fields={
          {name='num', type='uint8'}
      }}
   },
   [25608] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25609] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='ref_time', type='int32'}
   },
   [25610] = {
      {name='code', type='uint8'}
   },
   [25611] = {
      {name='result', type='uint8'},
      {name='score', type='uint32'},
      {name='get_score', type='int32'},
      {name='tar_name', type='string'},
      {name='tar_lev', type='uint16'},
      {name='tar_face', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='tar_score', type='int32'},
      {name='lose_score', type='int32'},
      {name='all_hurt_statistics', type='array', fields={
          {name='round', type='uint8'},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }}
      }}
   },
   [25612] = {
      {name='card_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='status', type='uint8'},
          {name='reward', type='array', fields={
              {name='item_id', type='uint32'},
              {name='num', type='uint32'}
          }},
          {name='val', type='array', fields={
              {name='item_id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [25613] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25614] = {
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='rank', type='uint32'},
          {name='lookid', type='uint32'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [25615] = {
      {name='rank', type='uint16'},
      {name='best_rank', type='uint16'},
      {name='arena_cluster_role', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='gname', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='power', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='score', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [25616] = {
      {name='type', type='uint8'},
      {name='arena_cluster_log', type='array', fields={
          {name='id', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='atk_name', type='string'},
          {name='atk_face', type='uint32'},
          {name='atk_lev', type='uint32'},
          {name='atk_rank', type='uint32'},
          {name='atk_score', type='uint32'},
          {name='atk_face_update_time', type='uint32'},
          {name='atk_face_file', type='string'},
          {name='def_rid', type='uint32'},
          {name='def_srv_id', type='string'},
          {name='def_name', type='string'},
          {name='def_face', type='uint32'},
          {name='def_lev', type='uint32'},
          {name='def_rank', type='uint32'},
          {name='def_score', type='uint32'},
          {name='def_face_update_time', type='uint32'},
          {name='def_face_file', type='string'},
          {name='ret', type='uint8'},
          {name='win_count', type='uint8'},
          {name='lose_count', type='uint8'},
          {name='combat_type', type='uint8'},
          {name='time', type='uint32'}
      }}
   },
   [25617] = {
      {name='type', type='uint8'},
      {name='id', type='uint32'},
      {name='arena_replay_infos', type='array', fields={
          {name='order', type='uint8'},
          {name='id', type='uint32'},
          {name='round', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint32'},
          {name='a_order', type='uint8'},
          {name='a_end_hp', type='uint8'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint32'},
          {name='b_order', type='uint8'},
          {name='b_end_hp', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [25618] = {
      {name='worship_code', type='uint8'},
      {name='reward_code', type='uint8'},
      {name='combat_code', type='uint8'}
   },
   [25700] = {
      {name='state', type='uint8'},
      {name='state_time', type='uint32'},
      {name='holiday_snatch_info', type='array', fields={
          {name='pos', type='uint32'},
          {name='id', type='uint32'},
          {name='num', type='uint32'},
          {name='state', type='uint8'},
          {name='state_time', type='uint32'},
          {name='ext', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='logs', type='array', fields={
          {name='win_name', type='string'},
          {name='join_num', type='uint32'},
          {name='max_num', type='uint32'},
          {name='time', type='uint32'},
          {name='award_name', type='string'},
          {name='awards', type='array', fields={
              {name='id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [25701] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25702] = {
      {name='is_win', type='uint8'},
      {name='win_num', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='win_name', type='string'},
      {name='win_face', type='uint32'},
      {name='win_lev', type='uint32'},
      {name='id', type='uint32'},
      {name='buy_nums', type='array', fields={
          {name='num', type='uint32'}
      }}
   },
   [25703] = {
      {name='logs', type='array', fields={
          {name='win_name', type='string'},
          {name='join_num', type='uint32'},
          {name='max_num', type='uint32'},
          {name='time', type='uint32'},
          {name='award_name', type='string'},
          {name='awards', type='array', fields={
              {name='id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [25704] = {
      {name='logs', type='array', fields={
          {name='is_win', type='uint8'},
          {name='win_num', type='uint32'},
          {name='buy_nums', type='array', fields={
              {name='num', type='uint32'}
          }},
          {name='time', type='uint32'},
          {name='award_name', type='string'},
          {name='awards', type='array', fields={
              {name='id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [25800] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='city_id', type='uint32'}
   },
   [25801] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='flag', type='uint8'}
   },
   [25802] = {
      {name='rank', type='uint16'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='rank', type='uint16'},
          {name='avatar_bid', type='uint32'},
          {name='fans_num', type='uint32'},
          {name='look_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [25805] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='pos', type='uint8'},
      {name='id', type='uint32'}
   },
   [25806] = {
      {name='point', type='uint32'},
      {name='honor_badges', type='array', fields={
          {name='id', type='uint32'},
          {name='time', type='uint32'}
      }},
      {name='use_badges', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }}
   },
   [25807] = {
      {name='id', type='uint32'}
   },
   [25810] = {
      {name='feat_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }},
      {name='finish_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish_time', type='uint32'}
      }}
   },
   [25811] = {
      {name='feat_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='end_time', type='uint32'},
          {name='finish_time', type='uint32'},
          {name='progress', type='array', fields={
              {name='id', type='uint16'},
              {name='finish', type='uint8'},
              {name='target', type='uint32'},
              {name='target_val', type='uint32'},
              {name='value', type='uint32'}
          }}
      }}
   },
   [25812] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='finish_time', type='uint32'}
   },
   [25813] = {
   },
   [25814] = {
      {name='result', type='uint8'}
   },
   [25815] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [25816] = {
      {name='id', type='uint32'},
      {name='finish_time', type='uint32'},
      {name='share_id', type='uint32'}
   },
   [25817] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [25818] = {
      {name='id', type='uint32'},
      {name='finish_time', type='uint32'},
      {name='share_id', type='uint32'}
   },
   [25819] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [25820] = {
      {name='point', type='uint32'},
      {name='num', type='uint32'},
      {name='share_id', type='uint32'}
   },
   [25830] = {
      {name='start', type='uint16'},
      {name='num', type='uint8'},
      {name='max_num', type='uint32'},
      {name='progress', type='array', fields={
          {name='id', type='uint32'},
          {name='order', type='uint32'},
          {name='time', type='uint32'},
          {name='arge', type='array', fields={
              {name='pos', type='uint8'},
              {name='val', type='string'}
          }}
      }}
   },
   [25831] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [25832] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='start', type='uint16'},
      {name='num', type='uint8'},
      {name='max_num', type='uint16'},
      {name='room_grow_info', type='array', fields={
          {name='id', type='uint32'},
          {name='order', type='uint32'},
          {name='time', type='uint32'},
          {name='arge', type='array', fields={
              {name='pos', type='uint8'},
              {name='val', type='string'}
          }}
      }}
   },
   [25833] = {
      {name='id', type='uint32'},
      {name='name', type='string'}
   },
   [25835] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [25836] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [25837] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='start', type='uint16'},
      {name='num', type='uint8'},
      {name='max_num', type='uint32'},
      {name='room_bbs_info', type='array', fields={
          {name='bbs_id', type='uint32'},
          {name='bbs_type', type='uint32'},
          {name='reply_name', type='string'},
          {name='msg', type='string'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='name', type='string'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [25838] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='bbs_id', type='uint32'}
   },
   [25839] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'}
   },
   [25840] = {
   },
   [25841] = {
      {name='max_num', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='room_bbs_info', type='array', fields={
          {name='bbs_id', type='uint32'},
          {name='bbs_type', type='uint32'},
          {name='reply_name', type='string'},
          {name='msg', type='string'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_id', type='uint32'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='name', type='string'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [25900] = {
      {name='period', type='uint8'},
      {name='open_day', type='uint8'},
      {name='is_open', type='uint8'}
   },
   [25901] = {
      {name='endtime', type='uint32'},
      {name='is_buy', type='uint8'}
   },
   [25910] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'}
      }},
      {name='endtime', type='uint32'},
      {name='period', type='uint32'}
   },
   [25911] = {
      {name='id', type='uint32'},
      {name='finish', type='uint8'},
      {name='target_val', type='uint32'},
      {name='value', type='uint32'}
   },
   [25912] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [25913] = {
      {name='endtime', type='uint32'},
      {name='buy_info', type='array', fields={
          {name='id', type='uint8'},
          {name='day_num', type='uint32'},
          {name='all_num', type='uint32'}
      }}
   },
   [25914] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [25915] = {
      {name='status_list', type='array', fields={
          {name='day', type='uint8'},
          {name='status', type='uint8'}
      }}
   },
   [25916] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='day', type='uint8'}
   },
   [25917] = {
      {name='endtime', type='uint32'},
      {name='discount_buy_count', type='array', fields={
          {name='package_id', type='uint32'},
          {name='buy_count', type='uint32'},
          {name='limit_count', type='uint32'}
      }}
   },
   [25918] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [25919] = {
      {name='bid', type='uint32'},
      {name='code', type='uint8'}
   },
   [25920] = {
      {name='endtime', type='uint32'}
   },
   [25921] = {
      {name='endtime', type='uint32'}
   },
   [26001] = {
      {name='name', type='string'},
      {name='look_id', type='uint32'},
      {name='worship', type='uint32'},
      {name='rest_worship', type='uint16'},
      {name='soft', type='uint32'},
      {name='wall_bid', type='uint32'},
      {name='land_bid', type='uint32'},
      {name='list', type='array', fields={
          {name='bid', type='uint32'},
          {name='index', type='uint32'},
          {name='dir', type='uint8'}
      }},
      {name='visitors', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='look_id', type='uint32'}
      }},
      {name='acc_hook_time', type='uint32'},
      {name='floor', type='uint8'},
      {name='main_floor', type='uint8'},
      {name='max_soft_floor', type='uint8'},
      {name='max_all_soft', type='uint32'},
      {name='other_bid', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='max_floor_soft', type='uint32'}
   },
   [26002] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='soft', type='uint32'},
      {name='wall_bid', type='uint32'},
      {name='land_bid', type='uint32'},
      {name='list', type='array', fields={
          {name='bid', type='uint32'},
          {name='index', type='uint32'},
          {name='dir', type='uint8'}
      }},
      {name='floor', type='uint8'},
      {name='max_soft_floor', type='uint8'},
      {name='max_all_soft', type='uint32'},
      {name='other_bid', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='max_floor_soft', type='uint32'}
   },
   [26003] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='look_id', type='uint32'},
      {name='worship', type='uint32'},
      {name='worship_status', type='uint8'},
      {name='soft', type='uint32'},
      {name='wall_bid', type='uint32'},
      {name='land_bid', type='uint32'},
      {name='list', type='array', fields={
          {name='bid', type='uint32'},
          {name='index', type='uint32'},
          {name='dir', type='uint8'}
      }},
      {name='visitors', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='look_id', type='uint32'}
      }},
      {name='tar_name', type='string'},
      {name='floor', type='uint8'}
   },
   [26004] = {
      {name='use_id', type='uint32'},
      {name='max_soft', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'}
      }},
      {name='is_finish', type='uint8'}
   },
   [26005] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [26006] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [26007] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [26008] = {
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='look_id', type='uint32'}
   },
   [26009] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='sex', type='uint8'},
          {name='face', type='uint32'},
          {name='power', type='uint32'},
          {name='last_login', type='uint32'},
          {name='soft', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [26010] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='face', type='uint32'},
          {name='lev', type='uint16'},
          {name='name', type='string'},
          {name='is_friend', type='uint8'},
          {name='type', type='uint8'},
          {name='time', type='uint32'},
          {name='int_args', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }},
          {name='str_args', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='string'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [26011] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='name', type='string'}
   },
   [26012] = {
      {name='worship', type='uint32'}
   },
   [26013] = {
      {name='list', type='array', fields={
          {name='set_id', type='uint32'},
          {name='reward', type='array', fields={
              {name='id', type='uint32'}
          }},
          {name='collect', type='array', fields={
              {name='bid', type='uint32'}
          }}
      }}
   },
   [26014] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [26015] = {
      {name='rest_worship', type='uint16'},
      {name='acc_hook_time', type='uint32'},
      {name='max_soft', type='uint32'}
   },
   [26016] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [26017] = {
      {name='is_first', type='uint8'}
   },
   [26018] = {
      {name='code', type='uint8'},
      {name='hook_code', type='uint8'}
   },
   [26019] = {
      {name='list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [26020] = {
      {name='my_rank', type='uint16'},
      {name='my_score', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='rank', type='uint16'},
          {name='avatar_bid', type='uint32'},
          {name='score', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [26021] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='main_floor', type='uint8'},
      {name='max_soft_floor', type='uint8'}
   },
   [26100] = {
      {name='pet_id', type='uint32'},
      {name='name', type='string'},
      {name='state', type='uint8'},
      {name='vigor', type='uint32'},
      {name='vigor_time', type='uint32'},
      {name='set_item', type='array', fields={
          {name='key', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='rename_count', type='uint32'},
      {name='day_talk', type='uint8'},
      {name='day_feed', type='uint8'}
   },
   [26101] = {
      {name='vigor', type='uint32'},
      {name='vigor_time', type='uint32'}
   },
   [26102] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='name', type='string'},
      {name='rename_count', type='uint32'}
   },
   [26103] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='flag', type='uint8'},
      {name='day_talk', type='uint8'},
      {name='day_feed', type='uint8'},
      {name='vigor', type='uint32'}
   },
   [26104] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='vigor', type='uint32'},
      {name='day_talk', type='uint8'},
      {name='day_feed', type='uint8'}
   },
   [26105] = {
      {name='evt_list', type='array', fields={
          {name='evt_id', type='uint32'},
          {name='time', type='uint32'},
          {name='evt_sid', type='uint32'},
          {name='award', type='array', fields={
              {name='id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [26106] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='flag', type='uint8'},
      {name='award', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='evt_id', type='uint32'}
   },
   [26107] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='set_item', type='array', fields={
          {name='key', type='uint8'},
          {name='id', type='uint32'}
      }}
   },
   [26108] = {
      {name='evt_list', type='array', fields={
          {name='evt_id', type='uint32'},
          {name='time', type='uint32'},
          {name='evt_sid', type='uint32'},
          {name='award', type='array', fields={
              {name='id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [26109] = {
      {name='start_time', type='uint32'},
      {name='evt_list', type='array', fields={
          {name='evt_id', type='uint32'},
          {name='time', type='uint32'},
          {name='evt_sid', type='uint32'},
          {name='award', type='array', fields={
              {name='id', type='uint32'},
              {name='num', type='uint32'}
          }}
      }},
      {name='city_id', type='uint32'}
   },
   [26110] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [26111] = {
      {name='type', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'}
      }}
   },
   [26112] = {
      {name='type', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'}
      }}
   },
   [26113] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint8'},
      {name='id', type='uint32'}
   },
   [26200] = {
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='step', type='uint8'},
      {name='step_status', type='uint8'},
      {name='step_status_time', type='uint32'},
      {name='round', type='uint8'},
      {name='round_status', type='uint8'},
      {name='round_status_time', type='uint32'},
      {name='flag', type='uint8'},
      {name='srv_id', type='string'},
      {name='is_open', type='uint8'}
   },
   [26201] = {
      {name='rank', type='uint16'},
      {name='best_rank', type='uint16'},
      {name='can_bet', type='uint32'},
      {name='group', type='uint8'}
   },
   [26202] = {
      {name='step', type='uint8'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_formation_type', type='uint8'},
      {name='a_formation_lev', type='uint8'},
      {name='a_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_formation_type', type='uint8'},
      {name='b_formation_lev', type='uint8'},
      {name='b_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='ret', type='uint8'},
      {name='replay_id', type='uint32'},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [26203] = {
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'},
      {name='a_bet_ratio', type='uint16'},
      {name='b_bet_ratio', type='uint16'},
      {name='step', type='uint8'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_formation_type', type='uint8'},
      {name='a_formation_lev', type='uint8'},
      {name='a_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_formation_type', type='uint8'},
      {name='b_formation_lev', type='uint8'},
      {name='b_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='ret', type='uint8'},
      {name='replay_id', type='uint32'},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [26204] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='can_bet', type='uint32'},
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'}
   },
   [26205] = {
      {name='list', type='array', fields={
          {name='id', type='uint16'},
          {name='target', type='uint8'},
          {name='bet', type='uint32'},
          {name='get_bet', type='uint32'},
          {name='step', type='uint8'},
          {name='round', type='uint8'},
          {name='group', type='uint8'},
          {name='a_bet', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='a_avatar_id', type='uint32'},
          {name='a_sex', type='uint8'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint8'},
          {name='a_formation_lev', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_bet', type='uint32'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='b_avatar_id', type='uint32'},
          {name='b_sex', type='uint8'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint8'},
          {name='b_formation_lev', type='uint8'},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [26206] = {
      {name='rank', type='uint16'},
      {name='cnum', type='uint8'},
      {name='win', type='uint8'}
   },
   [26207] = {
      {name='a_bet', type='uint32'},
      {name='b_bet', type='uint32'},
      {name='a_bet_ratio', type='uint16'},
      {name='b_bet_ratio', type='uint16'}
   },
   [26208] = {
      {name='list', type='array', fields={
          {name='id', type='uint16'},
          {name='score', type='uint16'},
          {name='step', type='uint8'},
          {name='round', type='uint8'},
          {name='group', type='uint8'},
          {name='a_bet', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='a_avatar_id', type='uint32'},
          {name='a_sex', type='uint8'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint8'},
          {name='a_formation_lev', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_bet', type='uint32'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='b_avatar_id', type='uint32'},
          {name='b_sex', type='uint8'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint8'},
          {name='b_formation_lev', type='uint8'},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='quality', type='uint8'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [26209] = {
      {name='list', type='array', fields={
          {name='group', type='uint8'},
          {name='pos_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='rid', type='uint32'},
              {name='srv_id', type='string'},
              {name='name', type='string'},
              {name='ret', type='uint8'},
              {name='replay_id', type='uint32'}
          }}
      }}
   },
   [26210] = {
      {name='pos_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='face', type='uint32'},
          {name='ret', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [26211] = {
      {name='group', type='uint8'},
      {name='pos', type='uint8'}
   },
   [26212] = {
      {name='step', type='uint8'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_formation_type', type='uint8'},
      {name='a_formation_lev', type='uint8'},
      {name='a_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_formation_type', type='uint8'},
      {name='b_formation_lev', type='uint8'},
      {name='b_plist', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='quality', type='uint8'},
          {name='star', type='uint8'},
          {name='break_lev', type='uint8'},
          {name='hurt', type='uint32'},
          {name='behurt', type='uint32'},
          {name='curt', type='uint32'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }},
      {name='ret', type='uint8'},
      {name='replay_id', type='uint32'},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [26213] = {
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='rank', type='uint8'},
          {name='sex', type='uint8'},
          {name='lookid', type='uint32'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }}
   },
   [26214] = {
      {name='rank', type='uint16'},
      {name='worship', type='uint32'},
      {name='power', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='score', type='uint16'},
          {name='power', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }},
      {name='score', type='uint32'}
   },
   [26215] = {
      {name='time', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [26216] = {
   },
   [26300] = {
      {name='end_time', type='uint32'},
      {name='count', type='uint8'},
      {name='award_id', type='uint32'}
   },
   [26301] = {
      {name='flag', type='uint8'}
   },
   [26400] = {
      {name='lev', type='uint32'},
      {name='list', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='attr', type='array', fields={
          {name='attr_id', type='uint32'},
          {name='attr_val', type='uint32'}
      }},
      {name='max_partner_lev', type='uint32'}
   },
   [26401] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26402] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26410] = {
      {name='all_num', type='uint32'},
      {name='do_num', type='uint32'},
      {name='get_num', type='uint32'},
      {name='do_end_time', type='uint32'},
      {name='is_point', type='uint8'}
   },
   [26411] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26412] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26413] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26414] = {
   },
   [26420] = {
      {name='star', type='uint8'},
      {name='num', type='uint8'}
   },
   [26421] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26422] = {
      {name='skills', type='array', fields={
          {name='skill_id', type='uint32'}
      }}
   },
   [26423] = {
      {name='partner_id', type='uint32'},
      {name='power', type='uint32'}
   },
   [26424] = {
      {name='partner_id', type='uint32'}
   },
   [26425] = {
      {name='lev', type='uint32'},
      {name='con_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'}
      }},
      {name='res_list', type='array', fields={
          {name='pos', type='uint32'},
          {name='id', type='uint32'},
          {name='cool_time', type='uint32'}
      }},
      {name='gold_count', type='uint32'},
      {name='item_count', type='uint32'},
      {name='max_cystal_lev', type='uint32'},
      {name='is_break', type='uint8'}
   },
   [26426] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26427] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26428] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='pos', type='uint32'}
   },
   [26429] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='pos', type='uint32'}
   },
   [26430] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26431] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='power', type='uint32'}
   },
   [26432] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26500] = {
      {name='sprite_hatchs', type='array', fields={
          {name='id', type='uint8'},
          {name='is_open', type='uint8'},
          {name='state', type='uint8'},
          {name='do_id', type='uint32'},
          {name='all_end_time', type='uint32'}
      }},
      {name='info', type='array', fields={
          {name='item_bid', type='uint32'},
          {name='buy_num', type='uint32'}
      }}
   },
   [26501] = {
      {name='sprite_hatch', type='array', fields={
          {name='id', type='uint8'},
          {name='is_open', type='uint8'},
          {name='state', type='uint8'},
          {name='do_id', type='uint32'},
          {name='all_end_time', type='uint32'}
      }}
   },
   [26502] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'},
      {name='lev', type='uint32'}
   },
   [26503] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [26504] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [26505] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [26506] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'},
      {name='awards', type='array', fields={
          {name='item_bid', type='uint32'},
          {name='item_num', type='uint32'}
      }}
   },
   [26507] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='item_id', type='uint32'},
      {name='count', type='uint8'}
   },
   [26508] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26509] = {
      {name='awards', type='array', fields={
          {name='item_bid', type='uint32'}
      }}
   },
   [26510] = {
      {name='lev', type='uint16'},
      {name='break_lev', type='uint16'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp_max', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='def', type='uint32'},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='power', type='uint32'}
   },
   [26511] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26512] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26513] = {
      {name='result', type='uint8'},
      {name='msg', type='string'}
   },
   [26514] = {
      {name='result', type='uint8'},
      {name='msg', type='string'},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [26520] = {
      {name='awards', type='array', fields={
          {name='item_bid', type='uint32'}
      }}
   },
   [26521] = {
      {name='camp_id', type='uint32'},
      {name='free_time', type='uint32'},
      {name='times', type='uint32'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='item_id', type='uint32'},
      {name='item_num', type='uint32'},
      {name='must_count', type='uint16'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'}
      }},
      {name='award_list', type='array', fields={
          {name='id', type='uint16'}
      }}
   },
   [26522] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26523] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26525] = {
      {name='group_id', type='uint16'},
      {name='times', type='uint8'},
      {name='rewards', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='sprite_bids', type='array', fields={
          {name='sprite_bid', type='uint32'},
          {name='quality', type='uint8'},
          {name='jie', type='uint16'}
      }}
   },
   [26530] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26535] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [26550] = {
      {name='camp_id', type='uint32'},
      {name='free_time', type='uint32'},
      {name='times', type='uint32'},
      {name='do_awards', type='array', fields={
          {name='award_id', type='uint32'}
      }},
      {name='lucky_ids', type='array', fields={
          {name='lucky_sprites_bid', type='uint32'}
      }},
      {name='day_count', type='uint32'}
   },
   [26551] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26552] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26553] = {
      {name='group_id', type='uint16'},
      {name='times', type='uint8'},
      {name='rewards', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='sprite_bids', type='array', fields={
          {name='sprite_bid', type='uint32'},
          {name='quality', type='uint8'},
          {name='jie', type='uint16'}
      }}
   },
   [26554] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26555] = {
      {name='type', type='uint32'},
      {name='team_list', type='array', fields={
          {name='team', type='uint32'},
          {name='sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='plan_id', type='uint8'}
      }}
   },
   [26556] = {
      {name='plan_list', type='array', fields={
          {name='id', type='uint8'},
          {name='name', type='string'},
          {name='plan_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [26557] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26558] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26559] = {
      {name='id', type='uint8'},
      {name='name', type='string'},
      {name='plan_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }}
   },
   [26560] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint32'},
      {name='team', type='uint32'}
   },
   [26561] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='type', type='uint32'},
      {name='team', type='uint32'}
   },
   [26562] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26563] = {
      {name='flag', type='uint8'},
      {name='type', type='uint8'},
      {name='id', type='uint32'},
      {name='name', type='string'}
   },
   [26564] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26600] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='time', type='uint32'},
      {name='sort', type='uint32'}
   },
   [26601] = {
      {name='time', type='uint32'},
      {name='last_time', type='uint32'},
      {name='lottery_id', type='uint32'},
      {name='sort_list', type='array', fields={
          {name='sort', type='uint32'}
      }}
   },
   [26602] = {
      {name='reward_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [26700] = {
      {name='round', type='uint8'},
      {name='end_time', type='uint32'},
      {name='difficulty', type='uint32'},
      {name='order', type='uint32'},
      {name='cha_count', type='uint32'},
      {name='buy_count', type='uint32'},
      {name='hp_per', type='uint32'},
      {name='boss_flag', type='uint8'},
      {name='paper_sum', type='uint32'},
      {name='boss_id', type='uint32'},
      {name='boss_time', type='uint32'},
      {name='boss_hp_per', type='uint32'},
      {name='dps', type='uint32'},
      {name='buff_per', type='uint32'},
      {name='boss_rank', type='uint32'}
   },
   [26701] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='buy_count', type='uint32'}
   },
   [26702] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [26703] = {
      {name='bossid', type='uint32'},
      {name='result', type='uint8'},
      {name='award_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [26704] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='paper_sum', type='uint32'}
   },
   [26705] = {
      {name='collect_schedule', type='array', fields={
          {name='id', type='uint8'},
          {name='staus', type='uint8'}
      }},
      {name='num', type='uint32'}
   },
   [26706] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'}
   },
   [26707] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [26708] = {
      {name='bossid', type='uint32'},
      {name='result', type='uint8'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='award_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [26709] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [26710] = {
      {name='rank', type='uint32'},
      {name='mydps', type='uint64'},
      {name='rank_per', type='uint32'},
      {name='next_power', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rank', type='uint32'},
          {name='r_rid', type='uint32'},
          {name='r_srvid', type='string'},
          {name='name', type='string'},
          {name='family_name', type='string'},
          {name='all_dps', type='uint64'},
          {name='face_id', type='uint32'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'}
      }}
   },
   [26711] = {
      {name='round', type='uint8'},
      {name='rank', type='uint32'},
      {name='count', type='uint32'},
      {name='order', type='uint8'}
   },
   [26712] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='flag', type='uint8'}
   },
   [26800] = {
      {name='count', type='uint32'},
      {name='last_buy_time', type='uint32'},
      {name='loss_list', type='array', fields={
          {name='loss_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='bid', type='uint32'},
      {name='hp', type='uint32'},
      {name='max_hp', type='uint32'},
      {name='end_time', type='uint32'},
      {name='count_time', type='uint32'},
      {name='boss_list', type='array', fields={
          {name='boss_id', type='uint32'}
      }},
      {name='progress_reward', type='array', fields={
          {name='order', type='uint32'}
      }},
      {name='dps', type='uint32'},
      {name='button', type='uint8'},
      {name='is_reward', type='uint8'}
   },
   [26801] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26802] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='combat_type', type='uint8'}
   },
   [26803] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint32'},
      {name='last_buy_time', type='uint32'}
   },
   [26804] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='number', type='uint32'}
   },
   [26805] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26806] = {
      {name='boss_id', type='uint32'},
      {name='dps_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='name', type='string'},
          {name='dps', type='uint32'},
          {name='rank', type='uint32'},
          {name='max_dps', type='uint32'},
          {name='power', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [26807] = {
      {name='flag', type='uint8'},
      {name='end_time', type='uint32'}
   },
   [26808] = {
      {name='flag', type='uint8'},
      {name='time', type='uint32'},
      {name='market_reward', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='boss_reward', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [26809] = {
      {name='result', type='uint8'},
      {name='reward', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [26810] = {
      {name='vitality', type='uint32'}
   },
   [26900] = {
      {name='item_list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='num', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='end_time', type='array', fields={
              {name='end_num', type='uint32'},
              {name='end_unixtime', type='uint32'}
          }},
          {name='score', type='uint32'}
      }},
      {name='day_buy', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [26901] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26902] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [26903] = {
      {name='board_list', type='array', fields={
          {name='type', type='uint8'},
          {name='name', type='string'},
          {name='operation', type='uint8'},
          {name='reward_list', type='array', fields={
              {name='base_id', type='uint32'},
              {name='num', type='uint32'}
          }},
          {name='unixtime', type='uint32'}
      }}
   },
   [26904] = {
      {name='item_list', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='num', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='end_time', type='array', fields={
              {name='end_num', type='uint32'},
              {name='end_unixtime', type='uint32'}
          }},
          {name='score', type='uint32'}
      }}
   },
   [26905] = {
      {name='item_list', type='array', fields={
          {name='id', type='uint32'},
          {name='num', type='uint32'},
          {name='end_time', type='array', fields={
              {name='end_num', type='uint32'},
              {name='end_unixtime', type='uint32'}
          }}
      }},
      {name='day_buy', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [26906] = {
      {name='id_list', type='array', fields={
          {name='id', type='uint32'}
      }},
      {name='day_buy', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [27000] = {
      {name='end_time', type='uint32'},
      {name='score', type='uint32'},
      {name='lev_score', type='uint32'},
      {name='score_award', type='array', fields={
          {name='id', type='uint16'},
          {name='status', type='uint8'}
      }}
   },
   [27001] = {
      {name='id', type='uint32'},
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='flag', type='uint32'}
   },
   [27002] = {
      {name='red_packet_list', type='array', fields={
          {name='red_packet_id', type='uint32'},
          {name='msg_id', type='uint16'},
          {name='name', type='string'},
          {name='status', type='uint8'}
      }},
      {name='get_num', type='uint16'},
      {name='max_num', type='uint16'}
   },
   [27003] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='get_red_packet_list', type='array', fields={
          {name='r_rid', type='uint32'},
          {name='r_srvid', type='string'},
          {name='red_id', type='uint32'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='time', type='uint32'},
          {name='item', type='array', fields={
              {name='item_id', type='uint16'},
              {name='num', type='uint32'}
          }}
      }},
      {name='red_packet_id', type='uint32'},
      {name='get_num', type='uint16'},
      {name='max_num', type='uint16'},
      {name='end_time', type='uint32'},
      {name='send_name', type='string'},
      {name='send_face_id', type='uint32'},
      {name='send_avatar_bid', type='uint32'}
   },
   [27004] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27005] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27006] = {
      {name='get_red_packet_list', type='array', fields={
          {name='r_rid', type='uint32'},
          {name='r_srvid', type='string'},
          {name='red_id', type='uint32'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='time', type='uint32'},
          {name='item', type='array', fields={
              {name='item_id', type='uint16'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [27007] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint16'}
   },
   [27008] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27100] = {
      {name='id', type='uint32'},
      {name='page', type='uint32'}
   },
   [27101] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27102] = {
      {name='id_list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [27103] = {
   },
   [27104] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27200] = {
      {name='team_list', type='array', fields={
          {name='tid', type='uint32'},
          {name='srv_id', type='string'},
          {name='team_name', type='string'},
          {name='team_power', type='uint32'},
          {name='team_limit_power', type='uint32'},
          {name='team_limit_lev', type='uint32'},
          {name='team_is_check', type='uint8'},
          {name='team_members', type='array', fields={
              {name='rid', type='uint32'},
              {name='sid', type='string'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='pos', type='uint16'},
              {name='ext', type='array', fields={
                  {name='extra_key', type='uint16'},
                  {name='extra_val', type='uint32'}
              }},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }}
      }},
      {name='do_join_list', type='array', fields={
          {name='tid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [27201] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27202] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='tid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [27203] = {
      {name='arena_team_member', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='team_partner', type='array', fields={
              {name='pos', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='star', type='uint16'},
              {name='break_lev', type='uint16'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [27204] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [27205] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [27206] = {
      {name='team_list', type='array', fields={
          {name='tid', type='uint32'},
          {name='srv_id', type='string'},
          {name='team_name', type='string'},
          {name='team_power', type='uint32'},
          {name='team_limit_power', type='uint32'},
          {name='team_limit_lev', type='uint32'},
          {name='team_is_check', type='uint8'},
          {name='team_members', type='array', fields={
              {name='rid', type='uint32'},
              {name='sid', type='string'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='pos', type='uint16'},
              {name='ext', type='array', fields={
                  {name='extra_key', type='uint16'},
                  {name='extra_val', type='uint32'}
              }},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }}
      }}
   },
   [27207] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27208] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27210] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='team_list', type='array', fields={
          {name='tid', type='uint32'},
          {name='srv_id', type='string'},
          {name='team_name', type='string'},
          {name='team_power', type='uint32'},
          {name='team_limit_power', type='uint32'},
          {name='team_limit_lev', type='uint32'},
          {name='team_is_check', type='uint8'},
          {name='team_members', type='array', fields={
              {name='rid', type='uint32'},
              {name='sid', type='string'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='pos', type='uint16'},
              {name='ext', type='array', fields={
                  {name='extra_key', type='uint16'},
                  {name='extra_val', type='uint32'}
              }},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }}
      }}
   },
   [27211] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27212] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27213] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27215] = {
      {name='point', type='array', fields={
          {name='type', type='uint8'},
          {name='state', type='uint8'}
      }}
   },
   [27216] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='do_join_list', type='array', fields={
          {name='tid', type='uint32'},
          {name='srv_id', type='string'}
      }}
   },
   [27220] = {
      {name='tid', type='uint32'},
      {name='srv_id', type='string'},
      {name='team_name', type='string'},
      {name='team_power', type='uint32'},
      {name='score', type='uint32'},
      {name='team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='state', type='uint8'},
      {name='end_time', type='uint32'},
      {name='rank', type='uint32'},
      {name='count', type='uint32'},
      {name='do_count', type='uint32'},
      {name='add_time', type='uint32'},
      {name='award_list', type='array', fields={
          {name='award_id', type='uint32'},
          {name='status', type='uint8'}
      }},
      {name='is_sign', type='uint8'}
   },
   [27221] = {
      {name='tid', type='uint32'},
      {name='srv_id', type='string'},
      {name='rid', type='uint32'},
      {name='sid', type='string'},
      {name='team_name', type='string'},
      {name='team_power', type='uint32'},
      {name='team_limit_power', type='uint32'},
      {name='team_limit_lev', type='uint32'},
      {name='team_is_check', type='uint8'},
      {name='arena_team_member', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='team_partner', type='array', fields={
              {name='pos', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='star', type='uint16'},
              {name='break_lev', type='uint16'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='is_sign', type='uint8'}
   },
   [27222] = {
      {name='type', type='uint16'}
   },
   [27223] = {
      {name='my_score', type='uint32'},
      {name='my_rank', type='uint32'},
      {name='ranks', type='array', fields={
          {name='team_name', type='string'},
          {name='team_power', type='uint32'},
          {name='score', type='uint32'},
          {name='rank', type='uint32'},
          {name='team_members', type='array', fields={
              {name='rid', type='uint32'},
              {name='sid', type='string'},
              {name='name', type='string'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='pos', type='uint16'},
              {name='ext', type='array', fields={
                  {name='extra_key', type='uint16'},
                  {name='extra_val', type='uint32'}
              }},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }}
      }}
   },
   [27224] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [27225] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27226] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27227] = {
      {name='rid', type='uint32'},
      {name='sid', type='string'},
      {name='is_online', type='uint8'}
   },
   [27228] = {
      {name='arena_team_member', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='team_partner', type='array', fields={
              {name='pos', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='star', type='uint16'},
              {name='break_lev', type='uint16'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [27229] = {
      {name='arena_team_member', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='team_partner', type='array', fields={
              {name='pos', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='star', type='uint16'},
              {name='break_lev', type='uint16'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [27240] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27241] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27242] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27243] = {
      {name='arena_team_member', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='team_partner', type='array', fields={
              {name='pos', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='star', type='uint16'},
              {name='break_lev', type='uint16'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='formation_type', type='uint32'},
          {name='hallows_id', type='uint32'},
          {name='sprite_lev', type='uint16'},
          {name='sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [27250] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27251] = {
      {name='rival_list', type='array', fields={
          {name='tid', type='uint32'},
          {name='srv_id', type='string'},
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='team_name', type='string'},
          {name='team_power', type='uint32'},
          {name='team_rank', type='uint32'},
          {name='team_score', type='uint32'},
          {name='team_members', type='array', fields={
              {name='rid', type='uint32'},
              {name='sid', type='string'},
              {name='name', type='string'},
              {name='lev', type='uint32'},
              {name='power', type='uint32'},
              {name='pos', type='uint32'},
              {name='is_hide', type='uint8'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='team_partner', type='array', fields={
                  {name='pos', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='star', type='uint16'},
                  {name='break_lev', type='uint16'},
                  {name='skin_id', type='uint32'},
                  {name='ext', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }}
              }},
              {name='ext', type='array', fields={
                  {name='extra_key', type='uint16'},
                  {name='extra_val', type='uint32'}
              }},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }}
      }}
   },
   [27252] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27253] = {
      {name='result', type='uint8'},
      {name='win_count', type='uint32'},
      {name='lose_count', type='uint32'},
      {name='a_score', type='int32'},
      {name='a_new_score', type='int32'},
      {name='a_rank', type='int32'},
      {name='a_new_rank', type='int32'},
      {name='a_team_name', type='string'},
      {name='a_team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='team_partner', type='array', fields={
              {name='pos', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='star', type='uint16'},
              {name='break_lev', type='uint16'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='b_score', type='int32'},
      {name='b_new_score', type='int32'},
      {name='b_rank', type='int32'},
      {name='b_new_rank', type='int32'},
      {name='b_team_name', type='string'},
      {name='b_team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='power', type='uint32'},
          {name='pos', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='team_partner', type='array', fields={
              {name='pos', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint32'},
              {name='star', type='uint16'},
              {name='break_lev', type='uint16'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='ext', type='array', fields={
              {name='extra_key', type='uint16'},
              {name='extra_val', type='uint32'}
          }},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='all_hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='a_round', type='uint8'},
          {name='b_round', type='uint8'},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }}
      }}
   },
   [27255] = {
      {name='arena_team_log', type='array', fields={
          {name='id', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='atk_name', type='string'},
          {name='a_score', type='uint32'},
          {name='a_new_score', type='uint32'},
          {name='a_rank', type='uint32'},
          {name='a_new_rank', type='uint32'},
          {name='a_team_power', type='uint32'},
          {name='a_team_members', type='array', fields={
              {name='rid', type='uint32'},
              {name='sid', type='string'},
              {name='name', type='string'},
              {name='lev', type='uint32'},
              {name='power', type='uint32'},
              {name='pos', type='uint32'},
              {name='is_hide', type='uint8'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='team_partner', type='array', fields={
                  {name='pos', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='star', type='uint16'},
                  {name='break_lev', type='uint16'},
                  {name='skin_id', type='uint32'},
                  {name='ext', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }}
              }},
              {name='ext', type='array', fields={
                  {name='extra_key', type='uint16'},
                  {name='extra_val', type='uint32'}
              }},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_score', type='int32'},
          {name='b_new_score', type='int32'},
          {name='b_rank', type='int32'},
          {name='b_new_rank', type='int32'},
          {name='b_team_name', type='string'},
          {name='b_team_power', type='uint32'},
          {name='b_team_members', type='array', fields={
              {name='rid', type='uint32'},
              {name='sid', type='string'},
              {name='name', type='string'},
              {name='lev', type='uint32'},
              {name='power', type='uint32'},
              {name='pos', type='uint32'},
              {name='is_hide', type='uint8'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='team_partner', type='array', fields={
                  {name='pos', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='star', type='uint16'},
                  {name='break_lev', type='uint16'},
                  {name='skin_id', type='uint32'},
                  {name='ext', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }}
              }},
              {name='ext', type='array', fields={
                  {name='extra_key', type='uint16'},
                  {name='extra_val', type='uint32'}
              }},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }},
          {name='ret', type='uint8'},
          {name='win_count', type='uint8'},
          {name='lose_count', type='uint8'},
          {name='time', type='uint32'}
      }}
   },
   [27256] = {
      {name='id', type='uint32'},
      {name='arena_replay_infos', type='array', fields={
          {name='order', type='uint8'},
          {name='id', type='uint32'},
          {name='round', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint32'},
          {name='a_order', type='uint8'},
          {name='a_end_hp', type='uint8'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint32'},
          {name='b_order', type='uint8'},
          {name='b_end_hp', type='uint8'},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='skin_id', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }}
      }}
   },
   [27300] = {
      {name='end_time', type='uint32'},
      {name='lev', type='uint32'},
      {name='score', type='uint32'},
      {name='max_score', type='uint32'},
      {name='reward', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [27301] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27400] = {
      {name='flag', type='uint8'},
      {name='end_time', type='uint32'},
      {name='stage', type='array', fields={
          {name='id', type='uint32'},
          {name='lock', type='uint32'},
          {name='develop', type='uint32'},
          {name='guild_develop', type='uint32'}
      }}
   },
   [27401] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint8'},
      {name='map_id', type='uint32'},
      {name='pos', type='uint32'},
      {name='develop', type='uint32'},
      {name='events', type='array', fields={
          {name='pos', type='uint32'},
          {name='type', type='uint32'}
      }},
      {name='now_type', type='uint8'},
      {name='guild_develop', type='uint32'},
      {name='look_id', type='uint32'}
   },
   [27403] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='num', type='uint32'},
      {name='pos', type='uint32'},
      {name='develop', type='uint32'},
      {name='now_type', type='uint8'},
      {name='id', type='uint32'},
      {name='guild_develop', type='uint32'}
   },
   [27404] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='pos', type='uint32'},
      {name='type', type='uint32'},
      {name='id', type='uint32'}
   },
   [27405] = {
      {name='id', type='uint32'},
      {name='choice', type='uint8'},
      {name='system_choice', type='uint8'},
      {name='ret', type='uint8'}
   },
   [27406] = {
      {name='type', type='uint8'}
   },
   [27407] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27408] = {
      {name='id', type='uint32'},
      {name='buffs', type='array', fields={
          {name='type', type='uint8'},
          {name='num', type='uint32'}
      }}
   },
   [27409] = {
      {name='id', type='uint32'},
      {name='buffs', type='array', fields={
          {name='type', type='uint8'}
      }},
      {name='reward', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [27410] = {
      {name='id', type='uint32'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='face', type='uint32'},
      {name='lev', type='uint8'},
      {name='power', type='uint32'},
      {name='guards', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [27500] = {
      {name='flag', type='uint8'},
      {name='end_time', type='uint32'},
      {name='id', type='uint8'},
      {name='develop', type='uint32'},
      {name='boss_list', type='array', fields={
          {name='boss_id', type='uint32'},
          {name='status', type='uint8'},
          {name='hp', type='uint32'},
          {name='max_hp', type='uint32'}
      }}
   },
   [27501] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27502] = {
      {name='id', type='uint8'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='dps', type='uint32'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='power', type='uint32'},
          {name='rank', type='uint32'},
          {name='worship_num', type='uint32'},
          {name='worship_status', type='uint32'}
      }}
   },
   [27503] = {
      {name='id', type='uint8'},
      {name='guild_stage_rank', type='array', fields={
          {name='gid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='dps', type='uint32'},
          {name='rank', type='uint32'},
          {name='leader_name', type='string'},
          {name='member', type='uint32'},
          {name='member_max', type='uint32'},
          {name='lev', type='uint32'}
      }},
      {name='r_gid', type='uint32'},
      {name='r_srv_id', type='string'},
      {name='r_name', type='string'},
      {name='r_dps', type='uint32'},
      {name='r_rank', type='uint32'},
      {name='r_leader_name', type='string'},
      {name='r_member', type='uint32'},
      {name='r_member_max', type='uint32'},
      {name='r_lev', type='uint32'}
   },
   [27504] = {
      {name='buffs', type='array', fields={
          {name='buff_id', type='uint8'},
          {name='val', type='uint32'}
      }}
   },
   [27505] = {
      {name='kill_num', type='uint8'},
      {name='all_num', type='uint32'}
   },
   [27506] = {
      {name='id', type='uint8'},
      {name='boss_id', type='uint8'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='award_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }}
   },
   [27600] = {
      {name='ids', type='array', fields={
          {name='id', type='uint32'}
      }},
      {name='flag', type='uint8'}
   },
   [27601] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [27602] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='is_first', type='uint8'},
      {name='is_formation', type='uint8'}
   },
   [27603] = {
   },
   [27700] = {
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='step', type='uint32'},
      {name='step_status', type='uint8'},
      {name='step_status_time', type='uint32'},
      {name='round', type='uint8'},
      {name='round_status', type='uint8'},
      {name='round_status_time', type='uint32'},
      {name='flag', type='uint8'},
      {name='period', type='uint32'},
      {name='zone_id', type='uint32'},
      {name='max_zone_id', type='uint32'}
   },
   [27701] = {
      {name='rank', type='uint16'},
      {name='best_rank', type='uint16'},
      {name='can_bet', type='uint32'},
      {name='group_256', type='uint8'},
      {name='group_64', type='uint8'}
   },
   [27702] = {
      {name='step', type='uint32'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_defense', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='power', type='uint32'},
          {name='plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_defense', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='power', type='uint32'},
          {name='plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }}
      }},
      {name='ret', type='uint8'},
      {name='result_info', type='array', fields={
          {name='order', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='round', type='uint8'},
          {name='a_end_hp', type='uint8'},
          {name='b_end_hp', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='replay_sid', type='string'}
      }},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='a_sprites_list', type='array', fields={
          {name='team', type='uint8'},
          {name='sprites_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }},
      {name='b_sprites_list', type='array', fields={
          {name='team', type='uint8'},
          {name='sprites_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [27703] = {
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'},
      {name='a_bet_ratio', type='uint16'},
      {name='b_bet_ratio', type='uint16'},
      {name='step', type='uint32'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_defense', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='power', type='uint32'},
          {name='plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_defense', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='power', type='uint32'},
          {name='plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }}
      }},
      {name='ret', type='uint8'},
      {name='result_info', type='array', fields={
          {name='order', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='round', type='uint8'},
          {name='a_end_hp', type='uint8'},
          {name='b_end_hp', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='replay_sid', type='string'}
      }},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='a_sprites_list', type='array', fields={
          {name='team', type='uint8'},
          {name='sprites_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }},
      {name='b_sprites_list', type='array', fields={
          {name='team', type='uint8'},
          {name='sprites_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [27704] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='can_bet', type='uint32'},
      {name='bet_type', type='uint8'},
      {name='bet_val', type='uint32'}
   },
   [27705] = {
      {name='list', type='array', fields={
          {name='id', type='uint16'},
          {name='target', type='uint8'},
          {name='bet', type='uint32'},
          {name='get_bet', type='uint32'},
          {name='step', type='uint32'},
          {name='round', type='uint8'},
          {name='group', type='uint8'},
          {name='a_bet', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='a_avatar_id', type='uint32'},
          {name='a_sex', type='uint8'},
          {name='a_power', type='uint32'},
          {name='a_defense', type='array', fields={
              {name='order', type='uint8'},
              {name='formation_type', type='uint8'},
              {name='hallows_id', type='uint32'},
              {name='hallows_look_id', type='uint32'},
              {name='power', type='uint32'},
              {name='plist', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='lev', type='uint16'},
                  {name='star', type='uint8'},
                  {name='break_lev', type='uint8'},
                  {name='power', type='uint32'},
                  {name='skin_id', type='uint32'},
                  {name='hurt', type='uint32'},
                  {name='behurt', type='uint32'},
                  {name='curt', type='uint32'},
                  {name='ext', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }}
              }}
          }},
          {name='b_bet', type='uint32'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='b_avatar_id', type='uint32'},
          {name='b_sex', type='uint8'},
          {name='b_power', type='uint32'},
          {name='b_defense', type='array', fields={
              {name='order', type='uint8'},
              {name='formation_type', type='uint8'},
              {name='hallows_id', type='uint32'},
              {name='hallows_look_id', type='uint32'},
              {name='power', type='uint32'},
              {name='plist', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='lev', type='uint16'},
                  {name='star', type='uint8'},
                  {name='break_lev', type='uint8'},
                  {name='power', type='uint32'},
                  {name='skin_id', type='uint32'},
                  {name='hurt', type='uint32'},
                  {name='behurt', type='uint32'},
                  {name='curt', type='uint32'},
                  {name='ext', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }}
              }}
          }},
          {name='ret', type='uint8'},
          {name='result_info', type='array', fields={
              {name='order', type='uint8'},
              {name='ret', type='uint8'},
              {name='time', type='uint32'},
              {name='round', type='uint8'},
              {name='a_end_hp', type='uint8'},
              {name='b_end_hp', type='uint8'},
              {name='replay_id', type='uint32'},
              {name='replay_sid', type='string'}
          }},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='a_sprites_list', type='array', fields={
              {name='team', type='uint8'},
              {name='sprites_list', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='item_bid', type='uint32'}
              }}
          }},
          {name='b_sprites_list', type='array', fields={
              {name='team', type='uint8'},
              {name='sprites_list', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='item_bid', type='uint32'}
              }}
          }}
      }}
   },
   [27706] = {
      {name='rank', type='uint16'},
      {name='cnum', type='uint8'},
      {name='win', type='uint8'}
   },
   [27707] = {
      {name='a_bet', type='uint32'},
      {name='b_bet', type='uint32'},
      {name='a_bet_ratio', type='uint16'},
      {name='b_bet_ratio', type='uint16'}
   },
   [27708] = {
      {name='list', type='array', fields={
          {name='id', type='uint16'},
          {name='score', type='uint16'},
          {name='step', type='uint32'},
          {name='round', type='uint8'},
          {name='group', type='uint8'},
          {name='a_bet', type='uint32'},
          {name='a_rid', type='uint32'},
          {name='a_srv_id', type='string'},
          {name='a_name', type='string'},
          {name='a_lev', type='uint16'},
          {name='a_face', type='uint32'},
          {name='a_face_update_time', type='uint32'},
          {name='a_face_file', type='string'},
          {name='a_avatar_id', type='uint32'},
          {name='a_sex', type='uint8'},
          {name='a_power', type='uint32'},
          {name='a_defense', type='array', fields={
              {name='order', type='uint8'},
              {name='formation_type', type='uint8'},
              {name='hallows_id', type='uint32'},
              {name='hallows_look_id', type='uint32'},
              {name='power', type='uint32'},
              {name='plist', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='lev', type='uint16'},
                  {name='star', type='uint8'},
                  {name='break_lev', type='uint8'},
                  {name='power', type='uint32'},
                  {name='skin_id', type='uint32'},
                  {name='hurt', type='uint32'},
                  {name='behurt', type='uint32'},
                  {name='curt', type='uint32'},
                  {name='ext', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }}
              }}
          }},
          {name='b_bet', type='uint32'},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_name', type='string'},
          {name='b_lev', type='uint16'},
          {name='b_face', type='uint32'},
          {name='b_face_update_time', type='uint32'},
          {name='b_face_file', type='string'},
          {name='b_avatar_id', type='uint32'},
          {name='b_sex', type='uint8'},
          {name='b_power', type='uint32'},
          {name='b_defense', type='array', fields={
              {name='order', type='uint8'},
              {name='formation_type', type='uint8'},
              {name='hallows_id', type='uint32'},
              {name='hallows_look_id', type='uint32'},
              {name='power', type='uint32'},
              {name='plist', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='lev', type='uint16'},
                  {name='star', type='uint8'},
                  {name='break_lev', type='uint8'},
                  {name='power', type='uint32'},
                  {name='skin_id', type='uint32'},
                  {name='hurt', type='uint32'},
                  {name='behurt', type='uint32'},
                  {name='curt', type='uint32'},
                  {name='ext', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }}
              }}
          }},
          {name='ret', type='uint8'},
          {name='result_info', type='array', fields={
              {name='order', type='uint8'},
              {name='ret', type='uint8'},
              {name='time', type='uint32'},
              {name='round', type='uint8'},
              {name='a_end_hp', type='uint8'},
              {name='b_end_hp', type='uint8'},
              {name='replay_id', type='uint32'},
              {name='replay_sid', type='string'}
          }},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='a_sprites_list', type='array', fields={
              {name='team', type='uint8'},
              {name='sprites_list', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='item_bid', type='uint32'}
              }}
          }},
          {name='b_sprites_list', type='array', fields={
              {name='team', type='uint8'},
              {name='sprites_list', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='item_bid', type='uint32'}
              }}
          }}
      }}
   },
   [27709] = {
      {name='zone_id', type='uint32'},
      {name='type', type='uint8'},
      {name='list', type='array', fields={
          {name='group', type='uint8'},
          {name='pos_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='rid', type='uint32'},
              {name='srv_id', type='string'},
              {name='name', type='string'},
              {name='lev', type='uint16'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='ret', type='uint8'},
              {name='ext', type='array', fields={
                  {name='ext_type', type='uint8'},
                  {name='ext_val', type='uint32'},
                  {name='ext_str_val', type='string'}
              }}
          }}
      }}
   },
   [27710] = {
      {name='zone_id', type='uint32'},
      {name='pos_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='ret', type='uint8'},
          {name='ext', type='array', fields={
              {name='ext_type', type='uint8'},
              {name='ext_val', type='uint32'},
              {name='ext_str_val', type='string'}
          }}
      }}
   },
   [27711] = {
      {name='group', type='uint8'},
      {name='pos', type='uint8'}
   },
   [27712] = {
      {name='zone_id', type='uint32'},
      {name='type', type='uint8'},
      {name='step', type='uint32'},
      {name='round', type='uint8'},
      {name='group', type='uint8'},
      {name='a_bet', type='uint32'},
      {name='a_rid', type='uint32'},
      {name='a_srv_id', type='string'},
      {name='a_name', type='string'},
      {name='a_lev', type='uint16'},
      {name='a_face', type='uint32'},
      {name='a_face_update_time', type='uint32'},
      {name='a_face_file', type='string'},
      {name='a_avatar_id', type='uint32'},
      {name='a_sex', type='uint8'},
      {name='a_power', type='uint32'},
      {name='a_defense', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='power', type='uint32'},
          {name='plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }}
      }},
      {name='b_bet', type='uint32'},
      {name='b_rid', type='uint32'},
      {name='b_srv_id', type='string'},
      {name='b_name', type='string'},
      {name='b_lev', type='uint16'},
      {name='b_face', type='uint32'},
      {name='b_face_update_time', type='uint32'},
      {name='b_face_file', type='string'},
      {name='b_avatar_id', type='uint32'},
      {name='b_sex', type='uint8'},
      {name='b_power', type='uint32'},
      {name='b_defense', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='power', type='uint32'},
          {name='plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='break_lev', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='hurt', type='uint32'},
              {name='behurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='ext', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }}
          }}
      }},
      {name='ret', type='uint8'},
      {name='result_info', type='array', fields={
          {name='order', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='round', type='uint8'},
          {name='a_end_hp', type='uint8'},
          {name='b_end_hp', type='uint8'},
          {name='replay_id', type='uint32'},
          {name='replay_sid', type='string'}
      }},
      {name='a_sprite_lev', type='uint16'},
      {name='a_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='b_sprite_lev', type='uint16'},
      {name='b_sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='a_sprites_list', type='array', fields={
          {name='team', type='uint8'},
          {name='sprites_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }},
      {name='b_sprites_list', type='array', fields={
          {name='team', type='uint8'},
          {name='sprites_list', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }}
      }}
   },
   [27713] = {
      {name='zone_id', type='uint32'},
      {name='period', type='uint32'},
      {name='arena_peak_rank', type='array', fields={
          {name='rank', type='uint16'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [27714] = {
      {name='rank', type='uint16'},
      {name='worship', type='uint32'},
      {name='power', type='uint32'},
      {name='score', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face_id', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='score', type='uint16'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='worship', type='uint32'},
          {name='worship_status', type='uint8'}
      }},
      {name='zone_id', type='uint32'},
      {name='start_num', type='uint32'},
      {name='end_num', type='uint32'},
      {name='day_worship', type='uint32'}
   },
   [27715] = {
      {name='time', type='uint32'},
      {name='rank_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='lev', type='uint16'},
          {name='face_id', type='uint32'},
          {name='sex', type='uint8'},
          {name='rank', type='uint16'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }}
   },
   [27716] = {
   },
   [27720] = {
      {name='zone_info', type='array', fields={
          {name='period', type='uint32'},
          {name='max_zone_id', type='uint32'},
          {name='self_zone_id', type='uint32'}
      }}
   },
   [27725] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27726] = {
      {name='formations', type='array', fields={
          {name='order', type='uint8'},
          {name='formation_type', type='uint8'},
          {name='pos_info', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'}
          }},
          {name='hallows_id', type='uint32'}
      }}
   },
   [27730] = {
      {name='point_info', type='array', fields={
          {name='type', type='uint8'},
          {name='is_point', type='uint8'}
      }}
   },
   [27731] = {
   },
   [27800] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='price', type='uint32'},
          {name='charge_id', type='uint32'},
          {name='limit_type', type='uint8'},
          {name='buy_num', type='uint32'},
          {name='limit_num', type='uint32'},
          {name='original_price', type='uint32'},
          {name='res_name', type='string'},
          {name='rank', type='uint32'},
          {name='icon', type='uint32'},
          {name='end_time', type='uint32'},
          {name='award_list', type='array', fields={
              {name='item_id', type='uint32'},
              {name='item_num', type='uint32'}
          }}
      }}
   },
   [27801] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27900] = {
      {name='flag', type='uint8'},
      {name='endtime', type='uint32'}
   },
   [27901] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27902] = {
      {name='period', type='uint16'},
      {name='open_day', type='uint16'},
      {name='is_open', type='uint8'}
   },
   [27903] = {
      {name='endtime', type='uint32'},
      {name='starttime', type='uint32'},
      {name='draw_time', type='uint32'},
      {name='limit_draw_time', type='uint32'},
      {name='free_time', type='uint8'},
      {name='award_list', type='array', fields={
          {name='type_id', type='uint32'},
          {name='get_count', type='uint32'},
          {name='limit_count', type='uint32'},
          {name='is_show', type='uint8'}
      }}
   },
   [27904] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [27905] = {
      {name='quest_list', type='array', fields={
          {name='id', type='uint32'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'},
          {name='ref_time', type='uint32'}
      }},
      {name='endtime', type='uint32'},
      {name='period', type='uint32'}
   },
   [27906] = {
      {name='id', type='uint32'},
      {name='finish', type='uint8'},
      {name='target_val', type='uint32'},
      {name='value', type='uint32'},
      {name='ref_time', type='uint32'}
   },
   [27907] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [27908] = {
      {name='endtime', type='uint32'},
      {name='status_list', type='array', fields={
          {name='day', type='uint16'},
          {name='status', type='uint8'}
      }}
   },
   [27909] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='day', type='uint16'}
   },
   [27910] = {
      {name='red_packet_list', type='array', fields={
          {name='red_packet_id', type='uint32'},
          {name='msg_id', type='uint16'},
          {name='name', type='string'},
          {name='status', type='uint8'}
      }},
      {name='get_num', type='uint16'},
      {name='max_num', type='uint16'}
   },
   [27911] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='get_red_packet_list', type='array', fields={
          {name='r_rid', type='uint32'},
          {name='r_srvid', type='string'},
          {name='red_id', type='uint32'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='time', type='uint32'},
          {name='item', type='array', fields={
              {name='item_id', type='uint16'},
              {name='num', type='uint32'}
          }}
      }},
      {name='red_packet_id', type='uint32'},
      {name='get_num', type='uint16'},
      {name='max_num', type='uint16'},
      {name='end_time', type='uint32'},
      {name='send_name', type='string'},
      {name='send_face_id', type='uint32'},
      {name='send_avatar_bid', type='uint32'}
   },
   [27912] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='get_num', type='uint16'},
      {name='max_num', type='uint16'}
   },
   [27913] = {
      {name='get_red_packet_list', type='array', fields={
          {name='r_rid', type='uint32'},
          {name='r_srvid', type='string'},
          {name='red_id', type='uint32'},
          {name='name', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='time', type='uint32'},
          {name='item', type='array', fields={
              {name='item_id', type='uint16'},
              {name='num', type='uint32'}
          }}
      }}
   },
   [27914] = {
      {name='endtime', type='uint32'},
      {name='get_count', type='uint32'},
      {name='limit_count', type='uint32'},
      {name='buy_info', type='array', fields={
          {name='id', type='uint32'},
          {name='day_num', type='uint32'},
          {name='all_num', type='uint32'}
      }}
   },
   [27915] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [27916] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28000] = {
      {name='gifts', type='array', fields={
          {name='end_time', type='uint32'},
          {name='count', type='uint8'},
          {name='award_id', type='uint32'}
      }}
   },
   [28100] = {
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='rsidue_gold', type='uint32'}
   },
   [28101] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28102] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28103] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28200] = {
      {name='camp_id', type='uint32'},
      {name='val', type='uint32'},
      {name='max_val', type='uint32'},
      {name='flag', type='uint8'},
      {name='end_time', type='uint32'},
      {name='last_red_pacekt_num', type='uint32'},
      {name='max_red_packet_num', type='uint32'},
      {name='look_id', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [28201] = {
      {name='index', type='uint32'},
      {name='map_id', type='uint32'},
      {name='tile_list', type='array', fields={
          {name='index', type='uint32'},
          {name='evtid', type='uint32'},
          {name='is_walk', type='uint8'},
          {name='res_id', type='uint32'}
      }}
   },
   [28202] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='index', type='uint32'}
   },
   [28203] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='index', type='uint32'},
      {name='action', type='uint8'}
   },
   [28204] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'},
      {name='is_first', type='uint8'}
   },
   [28205] = {
      {name='index', type='uint32'},
      {name='ext_list', type='array', fields={
          {name='type', type='uint32'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'}
      }}
   },
   [28206] = {
      {name='holiday_nian_item', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [28207] = {
      {name='update_item', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [28208] = {
      {name='delete_pos', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [28209] = {
      {name='type', type='uint8'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='use_skin', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='evt_index', type='uint32'},
      {name='reward', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='result', type='uint8'}
   },
   [28210] = {
      {name='unit_id', type='uint32'},
      {name='unit_lev', type='uint32'},
      {name='power', type='uint32'}
   },
   [28211] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28212] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28213] = {
      {name='dps_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='name', type='string'},
          {name='dps', type='uint32'},
          {name='power', type='uint32'},
          {name='rank', type='uint32'}
      }}
   },
   [28214] = {
      {name='flag', type='uint8'},
      {name='last_num', type='uint32'},
      {name='all_num', type='uint32'},
      {name='role_num', type='uint32'},
      {name='role_all_num', type='uint32'},
      {name='information', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='reward_list', type='array', fields={
              {name='base_id', type='uint32'},
              {name='num', type='uint32'}
          }},
          {name='unixtime', type='uint32'}
      }},
      {name='role_reward_list', type='array', fields={
          {name='role_base_id', type='uint32'},
          {name='role_num', type='uint32'}
      }}
   },
   [28215] = {
      {name='type', type='uint8'},
      {name='unit_id', type='uint32'},
      {name='combat_time', type='uint32'},
      {name='buy_time', type='uint32'},
      {name='last_time', type='uint32'},
      {name='index', type='uint32'}
   },
   [28216] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28217] = {
      {name='collection', type='array', fields={
          {name='id', type='uint32'},
          {name='last_num', type='uint32'},
          {name='flag', type='uint8'},
          {name='start_unixtime', type='uint32'},
          {name='end_unixtime', type='uint32'}
      }}
   },
   [28218] = {
      {name='tile_list', type='array', fields={
          {name='index', type='uint32'},
          {name='evtid', type='uint32'},
          {name='is_walk', type='uint8'},
          {name='res_id', type='uint32'}
      }}
   },
   [28219] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28220] = {
      {name='face', type='array', fields={
          {name='order', type='uint8'},
          {name='face_id', type='uint32'}
      }}
   },
   [28221] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='reward', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [28222] = {
      {name='player', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='name', type='string'},
          {name='look_id', type='uint32'},
          {name='honor_id', type='uint32'},
          {name='face', type='array', fields={
              {name='order', type='uint8'},
              {name='face_id', type='uint32'}
          }}
      }}
   },
   [28223] = {
      {name='flag', type='uint8'}
   },
   [28224] = {
      {name='timer_flag', type='uint8'},
      {name='gold_flag', type='uint8'}
   },
   [28300] = {
      {name='end_time', type='uint32'},
      {name='start_time', type='uint32'},
      {name='round', type='uint32'},
      {name='draw_time', type='uint32'},
      {name='optional_id', type='uint32'},
      {name='gold_time', type='uint32'},
      {name='next_round', type='uint8'},
      {name='award_list', type='array', fields={
          {name='id', type='uint32'},
          {name='pos', type='uint32'}
      }},
      {name='original_gold_time', type='uint32'}
   },
   [28301] = {
      {name='award_list', type='array', fields={
          {name='type_id', type='uint32'},
          {name='get_count', type='uint32'}
      }}
   },
   [28302] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28303] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='award_list', type='array', fields={
          {name='type_id', type='uint32'},
          {name='get_count', type='uint32'},
          {name='count', type='uint32'},
          {name='round', type='uint32'}
      }}
   },
   [28305] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28306] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28307] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28308] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28400] = {
      {name='period', type='uint8'},
      {name='start_time', type='uint32'},
      {name='end_time', type='uint32'},
      {name='info', type='array', fields={
          {name='period', type='uint8'},
          {name='state', type='uint8'},
          {name='quests', type='array', fields={
              {name='quest_id', type='uint32'},
              {name='val', type='uint32'},
              {name='finish', type='uint32'},
              {name='num', type='uint32'},
              {name='lucky_type', type='uint8'}
          }}
      }}
   },
   [28401] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28402] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28403] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28500] = {
      {name='end_time', type='uint32'},
      {name='lev', type='uint32'},
      {name='score', type='uint32'},
      {name='max_score', type='uint32'},
      {name='my_score', type='uint32'},
      {name='acc_score', type='uint32'},
      {name='max_acc_score', type='uint32'},
      {name='reward', type='array', fields={
          {name='id', type='uint32'}
      }}
   },
   [28501] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28502] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'}
   },
   [28600] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='line', type='uint32'},
      {name='index', type='uint32'},
      {name='action', type='uint8'}
   },
   [28601] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28602] = {
      {name='update_time', type='uint32'},
      {name='look_id', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'}
      }},
      {name='is_holiday', type='uint8'}
   },
   [28603] = {
      {name='floor', type='uint32'},
      {name='line', type='uint32'},
      {name='index', type='uint32'},
      {name='map_id', type='uint32'},
      {name='tile_list', type='array', fields={
          {name='line', type='uint32'},
          {name='index', type='uint32'},
          {name='evt_id', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='is_walk', type='uint8'},
          {name='combat_power', type='uint32'}
      }},
      {name='is_can_reward', type='uint8'},
      {name='is_reward', type='uint8'}
   },
   [28604] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28605] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28606] = {
      {name='floor', type='uint32'},
      {name='line', type='uint32'},
      {name='index', type='uint32'},
      {name='tile_list', type='array', fields={
          {name='line', type='uint32'},
          {name='index', type='uint32'},
          {name='evt_id', type='uint32'},
          {name='is_hide', type='uint8'},
          {name='is_walk', type='uint8'},
          {name='combat_power', type='uint32'}
      }}
   },
   [28607] = {
      {name='power', type='uint32'},
      {name='buffs', type='array', fields={
          {name='quality', type='uint8'},
          {name='num', type='uint32'}
      }},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'},
      {name='name', type='string'},
      {name='face', type='uint32'},
      {name='lev', type='uint8'},
      {name='guards_power', type='uint32'},
      {name='formation_type', type='uint32'},
      {name='guards', type='array', fields={
          {name='partner_id', type='uint32'},
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }},
          {name='hp_per', type='uint8'},
          {name='hp_max', type='uint32'},
          {name='atk', type='uint32'},
          {name='guards_power', type='uint32'}
      }},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='hallows_id', type='uint32'},
      {name='sprite_lev', type='uint32'},
      {name='strength', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='is_spar', type='uint8'}
   },
   [28608] = {
      {name='result', type='uint8'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='use_skin', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='award_list', type='array', fields={
          {name='bid', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='line', type='uint32'},
      {name='index', type='uint32'},
      {name='replay_id', type='uint32'}
   },
   [28609] = {
      {name='partners', type='array', fields={
          {name='flag', type='uint8'},
          {name='partner_id', type='uint32'},
          {name='hp_per', type='uint8'}
      }}
   },
   [28610] = {
      {name='power', type='uint32'}
   },
   [28611] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28612] = {
      {name='formation_type', type='uint8'},
      {name='pos_info', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='flag', type='uint8'}
      }},
      {name='hallows_id', type='uint32'}
   },
   [28613] = {
      {name='partners', type='array', fields={
          {name='flag', type='uint8'},
          {name='partner_id', type='uint32'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='power', type='uint32'},
          {name='hp_per', type='uint8'},
          {name='ext_data', type='array', fields={
              {name='key', type='uint32'},
              {name='val', type='uint32'}
          }}
      }}
   },
   [28614] = {
      {name='floor', type='uint32'},
      {name='line', type='uint32'},
      {name='index', type='uint32'},
      {name='ext_list', type='array', fields={
          {name='type', type='uint32'},
          {name='val1', type='uint32'},
          {name='val2', type='uint32'}
      }}
   },
   [28615] = {
      {name='id', type='uint32'}
   },
   [28616] = {
      {name='period', type='uint16'},
      {name='cur_day', type='uint32'},
      {name='end_time', type='uint32'},
      {name='lev', type='uint32'},
      {name='rmb_status', type='uint8'},
      {name='win_count', type='uint32'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='award_status', type='uint8'},
          {name='rmb_award_status', type='uint8'}
      }}
   },
   [28617] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28618] = {
      {name='flag', type='uint8'}
   },
   [28619] = {
      {name='is_pop', type='uint8'},
      {name='cur_day', type='uint32'}
   },
   [28620] = {
      {name='buffs', type='array', fields={
          {name='buff_id', type='uint32'}
      }}
   },
   [28621] = {
      {name='item_list', type='array', fields={
          {name='pos', type='uint8'},
          {name='id', type='uint32'},
          {name='is_flag', type='uint8'}
      }},
      {name='is_select', type='uint8'},
      {name='line', type='uint32'},
      {name='index', type='uint32'}
   },
   [28622] = {
      {name='line', type='uint32'},
      {name='index', type='uint32'},
      {name='planes_load_partner', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='break_skills', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_bid', type='uint32'}
          }},
          {name='break_lev', type='uint8'},
          {name='power', type='uint32'},
          {name='use_skin', type='uint32'},
          {name='end_time', type='uint32'},
          {name='atk', type='uint32'},
          {name='def_p', type='uint32'},
          {name='def_s', type='uint32'},
          {name='hp', type='uint32'},
          {name='speed', type='uint32'},
          {name='hit_rate', type='uint32'},
          {name='dodge_rate', type='uint32'},
          {name='crit_rate', type='uint32'},
          {name='crit_ratio', type='uint32'},
          {name='hit_magic', type='uint32'},
          {name='dodge_magic', type='uint32'},
          {name='def', type='uint32'},
          {name='eqms', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='type', type='uint32'}
          }},
          {name='artifacts', type='array', fields={
              {name='artifact_pos', type='uint8'},
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='enchant', type='uint32'},
              {name='attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='extra', type='array', fields={
                  {name='extra_k', type='uint32'},
                  {name='extra_v', type='uint32'}
              }}
          }},
          {name='holy_eqm', type='array', fields={
              {name='id', type='uint32'},
              {name='base_id', type='uint32'},
              {name='main_attr', type='array', fields={
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }},
              {name='holy_eqm_attr', type='array', fields={
                  {name='pos', type='uint8'},
                  {name='attr_id', type='uint32'},
                  {name='attr_val', type='uint32'}
              }}
          }},
          {name='dower_skill', type='array', fields={
              {name='pos', type='uint8'},
              {name='skill_id', type='uint32'}
          }}
      }}
   },
   [28623] = {
      {name='pos', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='skills', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_bid', type='uint32'}
      }},
      {name='break_lev', type='uint8'},
      {name='power', type='uint32'},
      {name='use_skin', type='uint32'},
      {name='end_time', type='uint32'},
      {name='atk', type='uint32'},
      {name='def_p', type='uint32'},
      {name='def_s', type='uint32'},
      {name='hp', type='uint32'},
      {name='speed', type='uint32'},
      {name='hit_rate', type='uint32'},
      {name='dodge_rate', type='uint32'},
      {name='crit_rate', type='uint32'},
      {name='crit_ratio', type='uint32'},
      {name='hit_magic', type='uint32'},
      {name='dodge_magic', type='uint32'},
      {name='def', type='uint32'},
      {name='eqms', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='type', type='uint32'}
      }},
      {name='artifacts', type='array', fields={
          {name='artifact_pos', type='uint8'},
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='enchant', type='uint32'},
          {name='attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='extra', type='array', fields={
              {name='extra_k', type='uint32'},
              {name='extra_v', type='uint32'}
          }}
      }},
      {name='holy_eqm', type='array', fields={
          {name='id', type='uint32'},
          {name='base_id', type='uint32'},
          {name='main_attr', type='array', fields={
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }},
          {name='holy_eqm_attr', type='array', fields={
              {name='pos', type='uint8'},
              {name='attr_id', type='uint32'},
              {name='attr_val', type='uint32'}
          }}
      }},
      {name='dower_skill', type='array', fields={
          {name='pos', type='uint8'},
          {name='skill_id', type='uint32'}
      }}
   },
   [28624] = {
      {name='is_can_reward', type='uint8'},
      {name='is_reward', type='uint8'}
   },
   [28625] = {
      {name='item_list', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [28626] = {
   },
   [28700] = {
      {name='period', type='uint8'},
      {name='cur_day', type='uint32'},
      {name='end_time', type='uint32'},
      {name='lev', type='uint32'},
      {name='exp', type='uint32'},
      {name='period_lev', type='uint32'},
      {name='day_lev', type='uint32'},
      {name='week_lev', type='uint32'},
      {name='rmb_status', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='type', type='uint8'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'},
          {name='end_time', type='uint32'}
      }}
   },
   [28701] = {
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='type', type='uint8'},
          {name='finish', type='uint8'},
          {name='target_val', type='uint32'},
          {name='value', type='uint32'},
          {name='end_time', type='uint32'}
      }}
   },
   [28702] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [28703] = {
      {name='lev', type='uint32'},
      {name='reward_list', type='array', fields={
          {name='id', type='uint16'},
          {name='status', type='uint8'},
          {name='rmb_status', type='uint8'}
      }}
   },
   [28704] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28705] = {
      {name='lev', type='uint32'},
      {name='exp', type='uint32'}
   },
   [28706] = {
      {name='rmb_status', type='uint8'},
      {name='list', type='array', fields={
          {name='id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [28707] = {
      {name='is_pop', type='uint8'},
      {name='cur_day', type='uint32'}
   },
   [28708] = {
      {name='flag', type='uint8'}
   },
   [28800] = {
      {name='id', type='uint32'},
      {name='time', type='uint8'},
      {name='buy_time', type='uint8'}
   },
   [28801] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28802] = {
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='use_skin', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='reward', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }}
   },
   [28803] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [28900] = {
      {name='gift_list', type='array', fields={
          {name='gift_id', type='uint32'},
          {name='charge_id', type='uint32'},
          {name='limit_count', type='uint8'},
          {name='costly_num', type='uint32'},
          {name='award', type='array', fields={
              {name='id', type='uint32'},
              {name='num', type='uint32'}
          }},
          {name='over_time', type='uint32'},
          {name='buy_count', type='uint8'},
          {name='desc', type='string'}
      }}
   },
   [28901] = {
      {name='flag', type='uint8'}
   },
   [29000] = {
      {name='end_time', type='uint32'},
      {name='state', type='uint16'},
      {name='count', type='uint16'},
      {name='buy_count', type='uint16'},
      {name='team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='is_online', type='uint8'}
      }},
      {name='award_list', type='array', fields={
          {name='award_id', type='uint32'},
          {name='status', type='uint8'}
      }},
      {name='team_count', type='uint16'}
   },
   [29001] = {
      {name='team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='is_online', type='uint8'}
      }}
   },
   [29002] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='rid', type='uint32'},
      {name='srv_id', type='string'}
   },
   [29003] = {
      {name='team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='is_online', type='uint8'}
      }}
   },
   [29004] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [29005] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [29006] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [29007] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [29008] = {
      {name='team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='is_online', type='uint8'}
      }}
   },
   [29009] = {
      {name='team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='is_online', type='uint8'}
      }}
   },
   [29010] = {
      {name='invite_list', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'}
      }}
   },
   [29016] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='atk_team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='formation_type', type='uint32'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='sprite_lev', type='uint32'},
          {name='sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='partner_infos', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='use_skin', type='uint32'},
              {name='resonate_lev', type='uint32'}
          }}
      }},
      {name='def_team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='formation_type', type='uint32'},
          {name='hallows_id', type='uint32'},
          {name='hallows_look_id', type='uint32'},
          {name='sprite_lev', type='uint32'},
          {name='sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='partner_infos', type='array', fields={
              {name='pos', type='uint8'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='use_skin', type='uint32'},
              {name='resonate_lev', type='uint32'}
          }}
      }},
      {name='ref_count', type='uint8'},
      {name='end_time', type='uint32'},
      {name='is_enter', type='uint8'}
   },
   [29017] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [29018] = {
   },
   [29019] = {
      {name='code', type='uint8'},
      {name='msg', type='string'}
   },
   [29020] = {
      {name='result', type='uint8'},
      {name='win_count', type='uint32'},
      {name='lose_count', type='uint32'},
      {name='score_lev', type='int32'},
      {name='new_score_lev', type='int32'},
      {name='score', type='int32'},
      {name='new_score', type='int32'},
      {name='rank', type='int32'},
      {name='new_rank', type='int32'},
      {name='all_hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='a_round', type='uint8'},
          {name='b_round', type='uint8'},
          {name='hurt_statistics', type='array', fields={
              {name='type', type='uint8'},
              {name='partner_hurts', type='array', fields={
                  {name='rid', type='uint32'},
                  {name='srvid', type='string'},
                  {name='id', type='uint32'},
                  {name='bid', type='uint32'},
                  {name='star', type='uint32'},
                  {name='lev', type='uint32'},
                  {name='camp_type', type='uint32'},
                  {name='dps', type='uint32'},
                  {name='cure', type='uint32'},
                  {name='ext_data', type='array', fields={
                      {name='key', type='uint32'},
                      {name='val', type='uint32'}
                  }},
                  {name='be_hurt', type='uint32'}
              }}
          }},
          {name='replay_id', type='uint32'},
          {name='a_name', type='string'},
          {name='b_name', type='string'},
          {name='ret', type='uint8'}
      }}
   },
   [29021] = {
      {name='rid', type='uint32'},
      {name='sid', type='string'},
      {name='name', type='string'},
      {name='face_id', type='uint32'},
      {name='power', type='uint32'},
      {name='avatar_bid', type='uint32'},
      {name='lev', type='uint32'},
      {name='pos', type='uint16'},
      {name='is_leader', type='uint8'},
      {name='rank', type='uint32'},
      {name='score', type='uint32'},
      {name='score_lev', type='uint32'},
      {name='face_update_time', type='uint32'},
      {name='face_file', type='string'},
      {name='formation_type', type='uint32'},
      {name='hallows_id', type='uint32'},
      {name='hallows_look_id', type='uint32'},
      {name='sprite_lev', type='uint32'},
      {name='sprites', type='array', fields={
          {name='pos', type='uint8'},
          {name='item_bid', type='uint32'}
      }},
      {name='partner_infos', type='array', fields={
          {name='pos', type='uint8'},
          {name='bid', type='uint32'},
          {name='lev', type='uint16'},
          {name='star', type='uint8'},
          {name='use_skin', type='uint32'},
          {name='resonate_lev', type='uint32'}
      }}
   },
   [29022] = {
   },
   [29025] = {
      {name='rank', type='uint32'},
      {name='team_members', type='array', fields={
          {name='rid', type='uint32'},
          {name='sid', type='string'},
          {name='name', type='string'},
          {name='face_id', type='uint32'},
          {name='power', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='lev', type='uint32'},
          {name='pos', type='uint16'},
          {name='is_leader', type='uint8'},
          {name='rank', type='uint32'},
          {name='score', type='uint32'},
          {name='score_lev', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'},
          {name='is_online', type='uint8'}
      }}
   },
   [29026] = {
      {name='holiday_arena_team_log', type='array', fields={
          {name='id', type='uint32'},
          {name='is_atk', type='uint8'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='atk_name', type='string'},
          {name='atk_face', type='array', fields={
              {name='pos', type='uint8'},
              {name='rid', type='uint32'},
              {name='srv_id', type='string'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='is_leader', type='uint32'},
              {name='lev', type='uint16'},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }},
          {name='atk_ole_rank', type='uint32'},
          {name='atk_rank', type='uint32'},
          {name='atk_ole_score', type='uint32'},
          {name='atk_score', type='uint32'},
          {name='def_rid', type='uint32'},
          {name='def_srv_id', type='string'},
          {name='def_name', type='string'},
          {name='def_face', type='array', fields={
              {name='pos', type='uint8'},
              {name='rid', type='uint32'},
              {name='srv_id', type='string'},
              {name='face_id', type='uint32'},
              {name='avatar_bid', type='uint32'},
              {name='is_leader', type='uint32'},
              {name='lev', type='uint16'},
              {name='face_update_time', type='uint32'},
              {name='face_file', type='string'}
          }},
          {name='def_ole_rank', type='uint32'},
          {name='def_rank', type='uint32'},
          {name='def_ole_score', type='uint32'},
          {name='def_score', type='uint32'},
          {name='ret', type='uint8'},
          {name='win_count', type='uint8'},
          {name='lose_count', type='uint8'},
          {name='time', type='uint32'},
          {name='atk_power', type='uint32'},
          {name='def_power', type='uint32'}
      }}
   },
   [29027] = {
      {name='id', type='uint32'},
      {name='replay_infos', type='array', fields={
          {name='order', type='uint8'},
          {name='id', type='uint32'},
          {name='round', type='uint8'},
          {name='ret', type='uint8'},
          {name='time', type='uint32'},
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='a_power', type='uint32'},
          {name='a_formation_type', type='uint32'},
          {name='a_order', type='uint8'},
          {name='a_end_hp', type='uint8'},
          {name='a_sprite_lev', type='uint16'},
          {name='a_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='b_rid', type='uint32'},
          {name='b_srv_id', type='string'},
          {name='b_power', type='uint32'},
          {name='b_formation_type', type='uint32'},
          {name='b_order', type='uint8'},
          {name='b_end_hp', type='uint8'},
          {name='b_sprite_lev', type='uint16'},
          {name='b_sprites', type='array', fields={
              {name='pos', type='uint8'},
              {name='item_bid', type='uint32'}
          }},
          {name='a_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='resonate_lev', type='uint32'},
              {name='hurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='be_hurt', type='uint32'}
          }},
          {name='b_plist', type='array', fields={
              {name='pos', type='uint8'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='lev', type='uint16'},
              {name='star', type='uint8'},
              {name='power', type='uint32'},
              {name='skin_id', type='uint32'},
              {name='resonate_lev', type='uint32'},
              {name='hurt', type='uint32'},
              {name='curt', type='uint32'},
              {name='be_hurt', type='uint32'}
          }},
          {name='a_name', type='string'},
          {name='b_name', type='string'}
      }}
   },
   [29028] = {
      {name='point', type='uint8'}
   },
   [29030] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='count', type='uint16'},
      {name='buy_count', type='uint16'}
   },
   [29031] = {
      {name='code', type='uint8'},
      {name='msg', type='string'},
      {name='id', type='uint32'},
      {name='award_list', type='array', fields={
          {name='award_id', type='uint32'},
          {name='status', type='uint8'}
      }}
   },
   [29035] = {
   },
   [29100] = {
      {name='flag', type='uint8'},
      {name='id', type='uint32'},
      {name='time', type='uint32'},
      {name='last_buy_time', type='uint32'},
      {name='radio', type='uint8'},
      {name='last_unixtime', type='uint32'},
      {name='practise_role_rank', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='name', type='string'},
          {name='val', type='uint32'},
          {name='unixtime', type='uint32'},
          {name='power', type='uint32'},
          {name='rank', type='uint32'},
          {name='video_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='role_rank', type='uint32'},
      {name='is_recombat', type='uint8'}
   },
   [29101] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [29102] = {
      {name='flag', type='uint8'},
      {name='all_dps', type='uint32'},
      {name='best_partner', type='uint32'},
      {name='bid', type='uint32'},
      {name='lev', type='uint16'},
      {name='star', type='uint8'},
      {name='use_skin', type='uint32'},
      {name='target_role_name', type='string'},
      {name='hurt_statistics', type='array', fields={
          {name='type', type='uint8'},
          {name='partner_hurts', type='array', fields={
              {name='rid', type='uint32'},
              {name='srvid', type='string'},
              {name='id', type='uint32'},
              {name='bid', type='uint32'},
              {name='star', type='uint32'},
              {name='lev', type='uint32'},
              {name='camp_type', type='uint32'},
              {name='dps', type='uint32'},
              {name='cure', type='uint32'},
              {name='ext_data', type='array', fields={
                  {name='key', type='uint32'},
                  {name='val', type='uint32'}
              }},
              {name='be_hurt', type='uint32'}
          }}
      }},
      {name='reward', type='array', fields={
          {name='base_id', type='uint32'},
          {name='num', type='uint32'}
      }},
      {name='last_anew_times', type='uint32'},
      {name='number', type='uint32'}
   },
   [29103] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [29104] = {
      {name='flag', type='uint8'},
      {name='msg', type='string'}
   },
   [29105] = {
      {name='flag', type='uint8'},
      {name='practise_role_rank', type='array', fields={
          {name='rid', type='uint32'},
          {name='srv_id', type='string'},
          {name='lev', type='uint32'},
          {name='face_id', type='uint32'},
          {name='avatar_bid', type='uint32'},
          {name='name', type='string'},
          {name='val', type='uint32'},
          {name='unixtime', type='uint32'},
          {name='power', type='uint32'},
          {name='rank', type='uint32'},
          {name='video_id', type='uint32'},
          {name='face_update_time', type='uint32'},
          {name='face_file', type='string'}
      }},
      {name='role_rank', type='uint32'},
      {name='role_val', type='uint32'},
      {name='role_unixtime', type='uint32'},
      {name='role_video_id', type='uint32'}
   },
   [29106] = {
      {name='role_rank', type='uint32'}
   },
   [29107] = {
   }
}

return Proto
