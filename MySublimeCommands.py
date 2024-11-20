import sublime
import sublime_plugin
import time

# sublime.log_commands(True)
# sublime.log_input(True)
# excute_update_script
# bpf_update_user_scripts

AllColors = (
  "darkgoldenrod",
  "darkmagenta",
  "darkolivegreen",
  "darkslateblue",
  "darkslategray",
  "darkviolet",
  "darkblue",
  "darkturquoise",
  "darkgray",
  "darkkhaki",
  "darkorange",
  "darksalmon",
  "darkseagreen",
  "brown"
)

FindResultsPrefix = r'Searching 1 file for "'

ApduPattern = r'(send|receive) data = 0x(21|12)(00|40)\S*'
T1pPattern = r'(send|receive) data = 0x(21|12)\S*'
SelectApduPattern = r'0[0-9]A4040[0-2]\S*'
ErrApduPattern = r'0x12[04]000026.[08].'
ErrStrongBoxApduPattern = r'0x12[04]0000.(81|1[89])0?[^0].*9000'
RotPattern = r'shared.secret|rootoftrust'
ProvisionToolPattern = r'StrongBoxProvision|EseImplement|smc_client|GdxProvisionTool'
ErrStrongBoxRspPattern = r'receive APDU:((81|1[89])0?[^0].*9000|6.[08].)'
ErrProvisionRspPattern = r'RECV\(.*\): (81|1[89])0?[^0].*9000'
ErrKeystore2Pattern = r'keystore2:     Error::'
RkpRequestStartPattern = r'Requested number of keys for provisioning|Key requested for : android.hardware.security.keymint.IRemotelyProvisionedComponent/'
KeystoreErrorPattern = r'keystore2:.*Error occurred:'
InvokeErrPattern = r'ca invoke teec command failed, err:'
ErrBpfApduPattern = r'0x12[04]0000B.*6.[08].9000|0x12[04]0000A.*44026.[08].'
BpfApduPattern = r'80A100[08]0\S*|80A010(510001|1164)\S*'
KeyMintApduPattern = r'8[0-3][0-4d].[46]000\S*'
FailErrPattern = r'fail(ed|ure)?|err(or)?|critical|fatal'
ErrorPattern = r'\[E\].*'
CMaintenancePattern = r'send data = 0x21DC00010[345]\S*'
RMaintenancePattern = r'receive data = 0x12DC00\S*'
SuccessPattern = r'success\S*'

# F8
NonprintableCharRegex = r'[^[:print:]\r\n\t]'
# F9
GsxaRegex = r'gs_ca|gs_ta|secure_element(@1.2)?-service-goodix'
GsxaHighlight = (
  # ('darkgoldenrod', r'operation_id is'), # gold
  ('darkgoldenrod', r'ese hardware reset successfull|DO_ESE_HARDWARE_RESET|GS_CMD_TEE_HARDWARE_RESET'), # gold
  ('darkseagreen', r'HAL Service is starting'), # green
  ('darkturquoise', r'runCosUpdateThread|runBackgroundThread|onstatechange'), # blue
  ('darkviolet', r'0[0-9]a40400\S*'), # purple
  ('brown', f'AEE_AED|critical|{ErrApduPattern}|{ErrStrongBoxApduPattern}|{InvokeErrPattern}|{ErrBpfApduPattern}|{ErrorPattern}'), # red
  ('darksalmon', f'{BpfApduPattern}'),
  )
# F10
ApduRegex = f'{ApduPattern}|(GOODIX|goodix).*HAL Service is starting'
ApduHighlight = (
  ('darkviolet', f'{SelectApduPattern}'),
  ('darkseagreen', r'HAL Service is starting'), # green
  ('darksalmon', f'{BpfApduPattern}'),
  ('darkgray', f'{KeyMintApduPattern}'),
  ('brown', f'{ErrApduPattern}|{ErrStrongBoxApduPattern}|{ErrBpfApduPattern}'),
  )
# F11
StrongboxRegex = r'keymint|strongbox|keystore|HalToHalTransport|rkpd|weaver|SecureElement-|SecureElementService'
StrongboxHighlight = (
  ('darkgoldenrod', f'{RotPattern}|rkpd|{RkpRequestStartPattern}|strongbox|onstatechange'),
  ('darkseagreen', r'HAL Service.* is starting'), # green
  ('brown', f'{ErrStrongBoxRspPattern}|{ErrKeystore2Pattern}|{KeystoreErrorPattern}|{FailErrPattern}'),
  )
# F12
ProvisionRegex = ProvisionToolPattern
ProvisionHighlight = (
  ('brown', f'{ErrProvisionRspPattern}|{FailErrPattern}'),
  )
# F7
BpfScriptRegex = f"(GOODIX|goodix).*HAL Service is starting|bpf|runCosUpdateThread|cos_update_cmd_update|load_update_script_file|check_is_se_installed_applet|load_update_script_list|execute_update_script|get_cos_version|get_preinstall_applet_version|gsn11_|gs_mt_print_se_hal_init_info|{ApduPattern}|{CMaintenancePattern}|{RMaintenancePattern}"
BpfScriptHighlight = (
  ('darkgoldenrod', r'gsn11_.*script|no useful.*scripts|cos is the latest|cos_version:.*$|runCosUpdateThread'), # gold
  ('darkviolet', f'{SelectApduPattern}'),
  ('darkseagreen', f'HAL Service is starting|{SuccessPattern}'), # green
  ('darksalmon', f'{BpfApduPattern}'),
  ('darkgray', f'{KeyMintApduPattern}'),
  ('darkturquoise', f'{CMaintenancePattern}'),
  ('brown', f'{ErrApduPattern}|{ErrBpfApduPattern}|{ErrorPattern}|{FailErrPattern}'),
  )
# F6
T1pRegex = f'{T1pPattern}|(GOODIX|goodix).*HAL Service is starting'
T1pHighlight = (
  ('darkviolet', f'{SelectApduPattern}'),
  ('darkgoldenrod', f'(21|12)[CE][F]'), # SWR
  ('darkturquoise', f'(21|12)[CE][3]'), # WTX
  ('darkseagreen', r'HAL Service is starting'), # green
  ('darksalmon', f'{BpfApduPattern}'),
  ('darkgray', f'{KeyMintApduPattern}'),
  ('brown', f'{ErrApduPattern}|{ErrStrongBoxApduPattern}|{ErrBpfApduPattern}'),
  )


toHighlight = False

class RemoveCharCommand(sublime_plugin.TextCommand):
  def run(self, edit):
    view = self.view
    window = view.window()
    window.run_command("focus_group", {"group": 0})
    window.run_command("show_panel", {"panel": "replace", "reverse": False})
    window.run_command("insert", {"characters": NonprintableCharRegex})
    window.run_command("replace_all", {"close_panel": True})

    global toHighlight
    toHighlight = True
    print(f'toHighlight={toHighlight}')

class FindGsxaCommand(sublime_plugin.TextCommand):
  def run(self, edit):
    view = self.view
    window = view.window()
    window.run_command("focus_group", {"group": 1})
    window.run_command("select_all")
    window.run_command("right_delete")
    window.run_command("focus_group", {"group": 0})
    window.run_command("show_panel", {"panel": "find_in_files"})
    window.run_command("insert", {"characters": GsxaRegex})
    window.run_command("find_all")

    window.run_command("focus_group", {"group": 1})
    window.run_command("text_marker_clear")
    # window.run_command("show_panel", {"panel": "find", "reverse": False})
    # window.run_command("insert", {"characters": })
    # window.run_command("find_all", {"close_panel": False})
    # window.focus_view(view)

    global toHighlight
    toHighlight = True
    print(f'toHighlight={toHighlight}')

class FindApduCommand(sublime_plugin.TextCommand):
  def run(self, edit):
    view = self.view
    window = view.window()
    window.run_command("focus_group", {"group": 1})
    window.run_command("select_all")
    window.run_command("right_delete")
    window.run_command("focus_group", {"group": 0})
    window.run_command("show_panel", {"panel": "find_in_files"})
    window.run_command("insert", {"characters": ApduRegex})
    window.run_command("find_all")

    window.run_command("focus_group", {"group": 1})
    window.run_command("text_marker_clear")

    global toHighlight
    toHighlight = True
    print(f'toHighlight={toHighlight}')

class FindStrongboxCommand(sublime_plugin.TextCommand):
  def run(self, edit):
    view = self.view
    window = view.window()
    window.run_command("focus_group", {"group": 1})
    window.run_command("select_all")
    window.run_command("right_delete")
    window.run_command("focus_group", {"group": 0})
    window.run_command("show_panel", {"panel": "find_in_files"})
    window.run_command("insert", {"characters": StrongboxRegex})
    window.run_command("find_all")

    window.run_command("focus_group", {"group": 1})
    window.run_command("text_marker_clear")

    global toHighlight
    toHighlight = True
    print(f'toHighlight={toHighlight}')

class FindProvisionCommand(sublime_plugin.TextCommand):
  def run(self, edit):
    view = self.view
    window = view.window()
    window.run_command("focus_group", {"group": 1})
    window.run_command("select_all")
    window.run_command("right_delete")
    window.run_command("focus_group", {"group": 0})
    window.run_command("show_panel", {"panel": "find_in_files"})
    window.run_command("insert", {"characters": ProvisionRegex})
    window.run_command("find_all")

    window.run_command("focus_group", {"group": 1})
    window.run_command("text_marker_clear")

    global toHighlight
    toHighlight = True
    print(f'toHighlight={toHighlight}')

class FindBpfScriptCommand(sublime_plugin.TextCommand):
  def run(self, edit):
    view = self.view
    window = view.window()
    window.run_command("focus_group", {"group": 1})
    window.run_command("select_all")
    window.run_command("right_delete")
    window.run_command("focus_group", {"group": 0})
    window.run_command("show_panel", {"panel": "find_in_files"})
    window.run_command("insert", {"characters": BpfScriptRegex})
    window.run_command("find_all")

    window.run_command("focus_group", {"group": 1})
    window.run_command("text_marker_clear")

    global toHighlight
    toHighlight = True
    print(f'toHighlight={toHighlight}')

class FindT1pCommand(sublime_plugin.TextCommand):
  def run(self, edit):
    view = self.view
    window = view.window()
    window.run_command("focus_group", {"group": 1})
    window.run_command("select_all")
    window.run_command("right_delete")
    window.run_command("focus_group", {"group": 0})
    window.run_command("show_panel", {"panel": "find_in_files"})
    window.run_command("insert", {"characters": T1pRegex})
    window.run_command("find_all")

    window.run_command("focus_group", {"group": 1})
    window.run_command("text_marker_clear")

    global toHighlight
    toHighlight = True
    print(f'toHighlight={toHighlight}')

class MyFindResultsListener(sublime_plugin.EventListener):

  markDone = False
  viewSize = 0
  activatedCount = 0

  def on_modified(self, view):
    print(f'on_modified invoked')
    self.markDone = False
    self.viewSize = 0

  def on_activated_async(self, view):
    global toHighlight
    doHighlight = False
    if view.name() == 'Find Results':
      print(f'activated toHighlight={toHighlight}')
      print('view size: ' + str(view.size()))

      # toHighlight = True if abs(self.viewSize - view.size()) > 10 else False
      if toHighlight:
        self.activatedCount += 1
        if self.activatedCount >= 3:
          doHighlight = True
          toHighlight = False
          self.activatedCount = 0

      self.viewSize = view.size()

      # point = view.sel()[0].begin()
      # view.insert(edit, point, "#############")

      # for color_scope_name in AllColors:
      #   regions = view.get_regions(color_scope_name)
      #   if regions:
      #     print(f'Found color regions: {color_scope_name}: {regions}')
      #     return

      line = view.substr(view.full_line(2))
      print(line)

      if doHighlight:
        if line.startswith(FindResultsPrefix + GsxaRegex):
          self.highlight(view, GsxaHighlight)
        elif line.startswith(FindResultsPrefix + ApduRegex):
          self.highlight(view, ApduHighlight)
        elif line.startswith(FindResultsPrefix + StrongboxRegex):
          self.highlight(view, StrongboxHighlight)
        elif line.startswith(FindResultsPrefix + ProvisionRegex):
          self.highlight(view, ProvisionHighlight)
        elif line.startswith(FindResultsPrefix + BpfScriptRegex):
          self.highlight(view, BpfScriptHighlight)
        elif line.startswith(FindResultsPrefix + T1pRegex):
          self.highlight(view, T1pHighlight)
        else:
          print('Find regex is not as expected!!!')

      self.markDone = True
      print(f'toHighlight={toHighlight}')

  def highlight(self, view, regexs):
    print('highlight find results...')
    view.run_command("text_marker_clear")
    for (color, regex) in regexs:
      print(f'color: {color}')
      print(f'regex: {regex}')
      regions = view.find_all(regex, flags=2)
      print('regions: ' + str(regions))
      # color_scope_name = color
      # view.add_regions(color_scope_name, regions, color_scope_name, '', 1)
      view_sel = view.sel()
      view_sel.clear()
      view_sel.add_all(regions)
      view.run_command("text_marker", {'color': color})
