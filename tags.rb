module Nanoc::Helpers
    replace_tag :toc do |ids, opts|
        render "toc", opts
    end

    replace_tag :autoindex,
            ai_sort_key: :identifier, ai_layout: 'ai_default' do |ids, opts|
        Nanoc::Helpers::AutoIndex.instance_exec ids.map{|i|
          item = @items["/#{i}/"]
          warn "Unknown item /#{i}/" if item == nil
          item
        }.compact, opts, &method(:render_index)
    end

    replace_tag :clearfix do |ids, opts|
        "<div class='clearfix' />"
    end

    replace_tag :glyph do |ids, opts|
        "<i class='fa #{ids.map{|id| "fa-#{id}"}.join(" ")}'></i>"
    end

    replace_tag :label, class: "default" do |ids, opts|
      "<span class='label label-#{opts[:class]}'>#{ids.join(" ")}</span>"
    end

    CLOSE_BTN = "<button type='button' class='close' data-dismiss='alert' markdown='0'><span aria-hidden='true'>&times;</span><span class='sr-only'>Close</span></button>"

    replace_tag :alert, class: "info", dismissible: "false", inline: "true" do |ids, opts|
      dismissible = YAML.load(opts[:dismissible])
      inline = YAML.load(opts[:inline]) ? "strong" : "h4"
      dismissible = false # Until issue gettalong:kramdown#173 is fixed
      title = ids.empty? ? "" : "<#{inline}>#{ids.join " "}</#{inline}>"
      "<div class='alert alert-#{opts[:class]}#{" alert-dismissible" if dismissible}' role='alert' markdown='block'>#{CLOSE_BTN if dismissible}#{title}"
    end

    replace_tag :end_alert do |ids, opts|
      "</div>"
    end

    replace_tag :collapse do |ids, opts|
        Nanoc::Helpers::skip_replacement "One id is required" unless ids.length > 0
      "<p><button class='btn btn-primary' type='button' data-toggle='collapse' data-target='##{ids[0]}' aria-expanded='false' aria-controls='#{ids[0]}'>#{opts[:title]}</button></p><div class='collapse' id='#{ids[0]}'><div class='card card-body' markdown='1'>\n"
    end

    replace_tag :end_collapse do |ids, opts|
      "\n</div></div>\n"
    end

    replace_tag :single_accordion, class: "panel-default" do |ids, opts|
        Nanoc::Helpers::skip_replacement "One id is required" unless ids.length > 0
      "<div class='panel-group' id='#{ids[0]}'><div class='panel #{opts[:class]}'><div class='panel-heading'><h4 class='panel-title'><a class='accordion-toggle' data-toggle='collapse' data-parent='#{'#' << ids[0]}' href='#{'#' << ids[0]}close'>#{opts[:title]}</a></h4></div><div id='#{ids[0]}close' class='panel-collapse collapse'><div class='panel-body' markdown='1'>\n"
    end

    replace_tag :multi_accordion, class: "panel-default" do |ids, opts|
        Nanoc::Helpers::skip_replacement "Two ids are required (group, item)" unless ids.length > 1
      "<div class='panel-group' id='#{ids[0]}'><div class='panel #{opts[:class]}'><div class='panel-heading'><h4 class='panel-title'><a class='accordion-toggle' data-toggle='collapse' data-parent='#{'#' << ids[0]}' href='#{'#' << ids[1]}'>#{opts[:title]}</a></h4></div><div id='#{ids[1]}' class='panel-collapse collapse'><div class='panel-body' markdown='1'>\n"
    end

    replace_tag :accordion, class: "panel-default" do |ids, opts|
        Nanoc::Helpers::skip_replacement "Two ids are required (group, item)" unless ids.length > 1
      "</div></div></div><div class='panel #{opts[:class]}'><div class='panel-heading'><h4 class='panel-title'><a class='accordion-toggle' data-toggle='collapse' data-parent='#{'#' << ids[0]}' href='#{'#' << ids[1]}'>#{opts[:title]}</a></h4></div><div id='#{ids[1]}' class='panel-collapse collapse'><div class='panel-body' markdown='1'>\n"
    end

    replace_tag :end_accordion do |ids, opts|
      "\n</div></div></div></div>\n"
    end

    replace_tag :include do |ids, opts|
      ids.map {|x|
        i = @items["/#{x}/"]
        if i == nil then
            warn "No such item: /#{x}/"
            ""
        elsif i.binary? then
          File.read(i.rep_named(opts.fetch(:rep, :default).to_sym).raw_path)
        else
          i.compiled_content(:rep => opts.fetch(:rep, :default).to_sym)
        end
      }.join("\n")
    end

    replace_tag :audio_player, icon: '/static/wav.png' do |ids, opts|
        Nanoc::Helpers::skip_replacement "The file attribute is required" unless opts[:file]
        file = opts[:file]
        icon = opts[:icon]
        title = html_escape(ids.join(' '))
        text = <<EOS
<div class='media' markdown='0'>
	<a class='pull-left' href='#{file}'><img class='media-object' src='#{icon}' alt='#{file}'></a>
	<div class='media-body'>
		<h4 class='media-heading'>#{title}</h4>
        <audio controls>
			<source src='#{file}' type='audio/x-wav'>
			<source src='#{file}' type='audio/wav'>
			<a src='#{file}'>#{title}</a>
		</audio>
    </div>
</div>
EOS
    end


    replace_tag :img, class: 'img-thumbnail', enlarge: true do |ids, opts|
        Nanoc::Helpers::skip_replacement "The file name attribute is required" unless opts[:file]
        title = html_escape(ids.join(' '))
        file = opts[:file]
        text = "<img class='img-responsive #{opts[:class]}' src='#{file}' title='#{title}' alt='#{title}'>"
        text = "<a href='#{file}' target='_blank'>#{text}</a>" if opts[:enlarge]
        text
    end
end
