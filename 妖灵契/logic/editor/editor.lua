if Utils.IsEditor() then
	editorgui = require "logic.editor.editorgui.editorgui"
	EditorDebug = require "logic.editor.EditorDebug"
end

CEditorArgBoxBase = require "logic.editor.CEditorArgBoxBase"
CEditorNormalArgBox = require "logic.editor.CEditorNormalArgBox"
CEditorComplexArgBox = require "logic.editor.CEditorComplexArgBox"

CEditorTimelineBox = require "logic.editor.CEditorTimelineBox"
CEditorTimelineView = require "logic.editor.CEditorTimelineView"
--技能编辑器
CEditorMagicView = require "logic.editor.editor_magic.CEditorMagicView"
CEditorMagicBuildCmdView = require "logic.editor.editor_magic.CEditorMagicBuildCmdView"
CEditorMagicCmdListBox = require "logic.editor.editor_magic.CEditorMagicCmdListBox"
CEditorMagicSaveAsView = require "logic.editor.editor_magic.CEditorMagicSaveAsView"

--buff编辑器
CEditorBuffView = require "logic.editor.editor_buff.CEditorBuffView"

--anim编辑器
CEditorAnimBox = require "logic.editor.editor_anim.CEditorAnimBox"
CEditorAnimSequence = require "logic.editor.editor_anim.CEditorAnimSequence"
CEditorAnimView = require "logic.editor.editor_anim.CEditorAnimView"

--摄像机
CEditorCameraSetupBox = require "logic.editor.editor_camera.CEditorCameraSetupBox"
CEditorCameraView = require "logic.editor.editor_camera.CEditorCameraView"

--站位
CEditorLineupView = require "logic.editor.editor_lineup.CEditorLineupView"

--table
CEditorTableView = require "logic.editor.editor_table.CEditorTableView"
CEditorTableBox = require "logic.editor.editor_table.CEditorTableBox"

--npc动画编辑器
CEditorDialogueCmdBox = require "logic.editor.editor_dilaogue_npc_ani.CEditorDialogueCmdBox"
CEditorDialogueCmdList = require "logic.editor.editor_dilaogue_npc_ani.CEditorDialogueCmdList"
CEditorDialogueNpcAnimView = require "logic.editor.editor_dilaogue_npc_ani.CEditorDialogueNpcAnimView"
CEditorDialogueCmdSpawnView = require "logic.editor.editor_dilaogue_npc_ani.CEditorDialogueCmdSpawnView"
CEditorDialogueSelectView = require "logic.editor.editor_dilaogue_npc_ani.CEditorDialogueSelectView"