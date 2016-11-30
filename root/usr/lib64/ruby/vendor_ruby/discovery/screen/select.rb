def screen_select select_what, org = nil, loc = nil, host_group = nil, mac = nil, gw = nil, proxy_url = cmdline('proxy.url'), proxy_type = cmdline('proxy.type')

  title = _("Select #{select_what} that the host will be discoverd with (Optional)")
  if select_what == 'Organization'
    selection = [ 'org1', 'org2', 'org3' ]
    next_screen = 'Location'
  elsif select_what == 'Location'
    selection = [ 'loc1', 'loc2' ]
    next_screen = 'Host Group'
  elsif select_what == 'Host Group'
    selection = [ 'host group1', 'host group2' ]
    next_screen = 'Proxy'
  elsif select_what == 'Proxy'
    selection = [ {:proxy_url => 'https://192.168.121.179', :proxy_type => 'foreman'}, {:proxy_url => 'https://proxy.example.com', :proxy_type => 'proxy'} ]
    title = _("Select #{select_what} that the host will be discoverd with")
  end

  Newt::Screen.centered_window(59, 20, _("Select an #{select_what})"))
  f = Newt::Form.new
  t_desc = Newt::Textbox.new(2, 1, 55, 3, Newt::FLAG_WRAP)
  t_desc.set_text title
  lb = Newt::Listbox.new(2, 5, 8, Newt::FLAG_SCROLL)
  if select_what == 'Proxy'
    selection.each_with_index do |proxy, index|
      lb.append("#{proxy[:proxy_url]} (#{proxy[:proxy_type]})", index)
    end
  else
    selection.each_with_index do |item, index|
      lb.append(item, index)
    end
  end
  lb.append("None", selection.length + 1)
  b_select = Newt::Button.new(9, 15, _("Select"))
  b_cancel = Newt::Button.new(41, 15, _("Cancel"))
  lb.set_width(55)

  f.add(t_desc, lb, b_select, b_cancel)

  answer = f.run
  if answer == b_select
    case select_what 
    when 'Organization'
      org = selection[lb.get_current_as_number] || nil
    when 'Location'
      loc = selection[lb.get_current_as_number] || nil
    when 'Host Group'
      host_group = selection[lb.get_current_as_number] || nil
    when 'Proxy'
      proxy_url = URI.parse(selection[lb.get_current_as_number][:proxy_url]) rescue nil
      proxy_type = selection[lb.get_current_as_number][:proxy_type] rescue nil
    end
    unless select_what == 'Proxy'
      [:screen_select, next_screen, org, loc, host_group, proxy_url, proxy_type ]
    else
      unless proxy_url.nil? && proxy_type.nil?
         [:screen_facts, mac, org, loc, host_group, proxy_url, proxy_type]
      else
         [:screen_foreman, mac, org, loc, host_group, proxy_url, proxy_type]
      end
    end
  else
    :screen_welcome
  end
end
