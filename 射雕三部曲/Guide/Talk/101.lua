
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },

    zm0= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p("@1","@2"), order  = 105,
            size   = 28, text = "@3",
            maxWidth = 580,
			opacity=0,
            color  = cc.c3b(255, 204, 124),
            time   =0,
        },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 28, text = "@1",
            -- maxWidth = 640,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =0.4,
        },},
    {delay = {time = 0.8,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
        },},
    },


    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },


jtt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },

jtttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },



jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放

        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},

    },


qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },





    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------

	 {
        music = {file = "backgroundmusic6.mp3",},
    },
    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 120,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    -- {
    --     model = {tag   = "curtain-window1",type  = DEF.WINDOW,
    --              size  = cc.size(DEF.WIDTH, 860),order = 99,
    --              pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5+380),},
    -- },
     {
        model = {
            tag   = "mapbj1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(320, -120),
            order = 99,opacity=255,
            file  = "bj.png",
        },
    },
     {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -100,
            file  = "bj.png",
        },
    },

    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },

    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1.5,
            pos   = cc.p(-900, -320),
            order = -99,
            file  = "huashan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },


    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 1060),},
    },



    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-1400","360","0.04","clip_1","50"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"lbyi","hero_nvzhu","-850","510","0.03","clip_1","50"},},
    },




    {
        model = {
            tag       = "guangxiao",     type      = DEF.FIGURE,
            pos= cc.p(-1180,500),     order     = 40,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 1.2,        loop      = true,opacity=150,
            endRlease = false,         parent = "clip_1", speed=0.8,rotation3D=cc.vec3(0,0,0),
        },},
    {
        model = {
            tag       = "guangxiao2",     type      = DEF.FIGURE,
            pos= cc.p(-1180,500),     order     = 41,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 1.2,        loop      = true,opacity=250,
            endRlease = false,         parent = "clip_1", speed=1.2,rotation3D=cc.vec3(0,180,0),
        },},

    {
        model = {
            tag       = "chuansong1",     type      = DEF.FIGURE,
            pos= cc.p(-1150,286),     order     = 30,
            file      = "effect_ui_chuansongmen",         animation = "zeizhao",
            scaleX     = 1.6,   scaleY=1.2  ,    loop      = true, opacity=100,
            endRlease = false,         parent = "clip_1", speed=1,
        },},
    {
        model = {
            tag       = "chuansong",     type      = DEF.FIGURE,
            pos= cc.p(-1180,480),     order     = 35,
            file      = "effect_ui_chuansongmen",         animation = "chuansongmen",
            scaleX     = 0.8,   scaleY     = 0.6,       loop      = true,
            endRlease = false,         parent = "clip_1", speed=0.3,
        },},


     {
         load = {tmpl = "mod3111",
             params = {"effect_ui_shenbingqjinjie","0.25","-1180","450","clip_1"},},
     },



    {delay={time=0.15},},

    {
        model = {
            tag       = "xiangzi",     type      = DEF.FIGURE,
            pos= cc.p(-1175,470),     order     = 101,
            file      = "effect_jinlun",         animation = "animation",
            scale     = 0.09,         loop      = true,
            endRlease = false,         parent = "clip_1", speed=2,
        },},


    {
        model = { tag = "yupan",type  = DEF.PIC,
                  file  = "yp.png",order = 100,scale=0.1,
                  pos   = cc.p(-1180, 450),parent = "clip_1",rotation3D=cc.vec3(30,30,0),},
    },








     {
         load = {tmpl = "jt",
             params = {"clip_1","2","1","1140","0"},},
     },





    {
       delay = {time = 0.5,},
    },


    -- {action = {tag  = "lwshuang",sync = false,what = {loop = {sequence = {{rotate =
    --              {to  = cc.vec3(0,-200,0),time = 1, },},
    --         {rotate = {to= cc.vec3(0,-160,0),time = 1,},},},},},},},



    -- {
    --     action = { tag  = "curtain-window",
    --         sync = true,time = 0.6,
    --         size = cc.size(DEF.WIDTH, 0),},
    -- },




    -- {
    --     action = { tag  = "curtain-window1",
    --         sync = true,time = 0.6,
    --         size = cc.size(DEF.WIDTH, 860),},
    -- },
     -- {action = {
     --         tag  = "mapbj1",sync = true,what = {
     --         spawn = {{move = {time = 0.5,by= cc.p(0, 0), },},{fadein = {time = 1.5,},},},
     --        },},},
     {
         load = {tmpl = "zm0",
             params = {"640","450",TR("华山之巅，时空破碎，有秘宝现世……")},},
     },
     {action = {
             tag  = "450",sync = true,what = {
             spawn = {{move = {time = 1.5,by= cc.p(-250, 0), },},{fadein = {time = 0.5,},},},
            },},},
    {
        delay = {time = 0.6,},
    },
     {
         load = {tmpl = "zm0",
             params = {"240","400",TR("传说秘宝中藏有绝世武功")},},
     },
     {action = {
             tag  = "400",sync = true,what = {
             spawn = {{move = {time = 1.5,by= cc.p(240, 0), },},{fadein = {time = 0.5,},},},
            },},},
    {
        delay = {time = 0.6,},
    },
     {
         load = {tmpl = "zm0",
             params = {"640","350",TR("得之将天下无敌")},},
     },
     {action = {
             tag  = "350",sync = true,what = {
             spawn = {{move = {time = 1.5,by= cc.p(-230, 0), },},{fadein = {time = 0.5,},},},
            },},},
    {
        delay = {time = 0.6,},
    },
     {
         load = {tmpl = "zm0",
             params = {"240","300",TR("一时间，天下群雄，纷至沓来……")},},
     },
     {action = {
             tag  = "300",sync = true,what = {
             spawn = {{move = {time = 1.5,by= cc.p(220, 0), },},{fadein = {time = 0.5,},},},
            },},},
    {
        delay = {time = 0.6,},
    },


    {
        delay = {time = 2,},
    },


    {remove = { model = {"300", "450","400", "350", }, },},




    --  {
    --      load = {tmpl = "zm0",
    --          params = {"640","660",TR("得之者……")},},
    --  },
    --  {action = {
    --          tag  = "660",sync = true,what = {
    --          spawn = {{move = {time = 1.5,by= cc.p(-200, 0), },},{fadein = {time = 0.5,},},},
    --         },},},

    --  {
    --      load = {tmpl = "zm0",
    --          params = {"240","600",TR("将独步武林！")},},
    --  },
    --  {action = {
    --          tag  = "600",sync = true,what = {
    --          spawn = {{move = {time = 1.5,by= cc.p(280, 0), },},{fadein = {time = 0.5,},},},
    --         },},},
    -- {
    --     delay = {time = 0.6,},
    -- },
    --  {
    --      load = {tmpl = "zm0",
    --          params = {"640","540",TR("秘宝的出现，错乱了时空……")},},
    --  },
    --  {action = {
    --          tag  = "540",sync = true,what = {
    --          spawn = {{move = {time = 1.5,by= cc.p(-230, 0), },},{fadein = {time = 0.5,},},},
    --         },},},

    --  {
    --      load = {tmpl = "zm0",
    --          params = {"240","480",TR("不同时代的高手，纷至沓来！")},},
    --  },
    --  {action = {
    --          tag  = "480",sync = true,what = {
    --          spawn = {{move = {time = 1.5,by= cc.p(260, 0), },},{fadein = {time = 0.5,},},},
    --         },},},
    -- {
    --     delay = {time = 0.6,},
    -- },
    --  {
    --      load = {tmpl = "zm0",
    --          params = {"640","420",TR("中原武林……")},},
    --  },
    --  {action = {
    --          tag  = "420",sync = true,what = {
    --          spawn = {{move = {time = 1.5,by= cc.p(-200, 0), },},{fadein = {time = 0.5,},},},
    --         },},},

    --  {
    --      load = {tmpl = "zm0",
    --          params = {"240","360",TR("即将掀起一场腥风血雨……")},},
    --  },
    --  {action = {
    --          tag  = "360",sync = true,what = {
    --          spawn = {{move = {time = 1.5,by= cc.p(280, 0), },},{fadein = {time = 0.5,},},},
    --         },},},








    -- {   model = {
    --         tag  = "hqgong",     type  = DEF.FIGURE,
    --         pos= cc.p(-1400,200),    order     = 45,
    --         file = "hero_guojing",    animation = "pugong",
    --         scale = 0.09,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,15),
    --     },},

    -- {   model = {
    --         tag  = "oyfeng",     type  = DEF.FIGURE,
    --         pos= cc.p(-900,-50),    order     = 45,
    --         file = "hero_ouyangfeng",    animation = "nuji",
    --         scale = 0.09,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,180,15),
    --     },},




    -- {   model = {
    --         tag  = "hqgong",     type  = DEF.FIGURE,
    --         pos= cc.p(-1400,200),    order     = 45,
    --         file = "hero_hongqigong",    animation = "nuji",
    --         scale = 0.09,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=4, rotation3D=cc.vec3(0,0,15),
    --     },},

    -- {   model = {
    --         tag  = "oyfeng",     type  = DEF.FIGURE,
    --         pos= cc.p(-900,-50),    order     = 45,
    --         file = "hero_ouyangfeng",    animation = "nuji",
    --         scale = 0.09,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=4, rotation3D=cc.vec3(0,180,15),
    --     },},

    -- {   model = {
    --         tag  = "hqgong1",     type  = DEF.FIGURE,
    --         pos= cc.p(-1200,160),    order     = 47,
    --         file = "effect_hongqigong_nuji",    animation = "animation",
    --         scale = 0.2,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=0.75, rotation3D=cc.vec3(0,0,0),
    --     },},

    -- {   model = {
    --         tag  = "hqgong2",     type  = DEF.FIGURE,
    --         pos= cc.p(-1300,200),    order     = 47,
    --         file = "effect_hongqigong_nuji",    animation = "animation",
    --         scale = 0.2,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=0.75, rotation3D=cc.vec3(0,0,0),
    --     },},
    -- {
    --    delay = {time = 0.5,},
    -- },

    -- {
    --     model = {
    --         tag = "hqgong",
    --         speed = 0,
    --     },
    -- },

    -- {
    --     model = {
    --         tag = "oyfeng",
    --         speed = 0,
    --     },
    -- },
    -- {
    --     model = {
    --         tag = "hqgong1",
    --         speed = 0,
    --     },
    -- },
    -- {
    --     model = {
    --         tag = "hqgong2",
    --         speed = 0,
    --     },
    -- },



    -- {
    --     model = {
    --         tag = "hqgong",
    --         speed = 0.25,
    --     },
    -- },

    -- {
    --     model = {
    --         tag = "oyfeng",
    --         speed = 1,
    --     },
    -- },
    -- {
    --     model = {
    --         tag = "hqgong1",
    --         speed = 0.5,
    --     },
    -- },
    -- {
    --     model = {
    --         tag = "hqgong2",
    --         speed = 0.8,
    --     },
    -- },




     -- {
     --     load = {tmpl = "zm0",
     --         params = {"640","900",TR("江湖传闻……")},},
     -- },
     -- {action = {
     --         tag  = "900",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(-280, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"120","840",TR("华山之巅，有异宝现世！")},},
     -- },
     -- {action = {
     --         tag  = "840",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(320, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"640","780",TR("传说……")},},
     -- },
     -- {action = {
     --         tag  = "780",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(-280, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"120","720",TR("异宝中藏有无数绝妙武功！")},},
     -- },
     -- {action = {
     --         tag  = "720",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(320, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"640","660",TR("得异宝者……")},},
     -- },
     -- {action = {
     --         tag  = "660",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(-280, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"120","600",TR("武功将冠绝天下，独步武林！")},},
     -- },
     -- {action = {
     --         tag  = "600",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(320, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"640","540",TR("异宝的出现错乱了时空……")},},
     -- },
     -- {action = {
     --         tag  = "540",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(-280, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"120","480",TR("不同时代的江湖高手……纷至沓来！")},},
     -- },
     -- {action = {
     --         tag  = "480",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(320, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"640","420",TR("一场血雨腥风……")},},
     -- },
     -- {action = {
     --         tag  = "420",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(-280, 0), },},{fadein = {time = 0.5,},},},
     --        },},},

     -- {
     --     load = {tmpl = "zm0",
     --         params = {"120","360",TR("即将展开……")},},
     -- },
     -- {action = {
     --         tag  = "360",sync = true,what = {
     --         spawn = {{move = {time = 1.5,by= cc.p(320, 0), },},{fadein = {time = 0.5,},},},
     --        },},},



    {
       delay = {time = 0.1,},
    },

----正式剧情

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },


    {
	   delay = {time = 0.1,},
	},
}
