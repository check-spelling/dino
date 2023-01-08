using Gee;
using Gdk;
using Gtk;

using Dino.Entities;

namespace Dino.Ui {

public class FileImageWidget : Box {

    FileDefaultWidget file_default_widget;
    FileDefaultWidgetController file_default_widget_controller;

    public FileImageWidget() {
        this.halign = Align.START;

        this.add_css_class("file-image-widget");
    }

    public async void load_from_file(File file, string file_name, int MAX_WIDTH=600, int MAX_HEIGHT=300) throws GLib.Error {
        FixedRatioPicture image = new FixedRatioPicture() { min_width = 100, min_height = 100, max_width = MAX_WIDTH, max_height = MAX_HEIGHT, file = file };

        FileInfo file_info = file.query_info("*", FileQueryInfoFlags.NONE);
        string? mime_type = file_info.get_content_type();

        file_default_widget = new FileDefaultWidget() { valign=Align.END, vexpand=false, visible=false };
        file_default_widget.image_stack.visible = false;
        file_default_widget_controller = new FileDefaultWidgetController(file_default_widget);
        file_default_widget_controller.set_file(file, file_name, mime_type);

        Overlay overlay = new Overlay();
        overlay.set_child(image);
        overlay.add_overlay(file_default_widget);
        overlay.set_measure_overlay(image, true);
        overlay.set_clip_overlay(file_default_widget, true);

        EventControllerMotion this_motion_events = new EventControllerMotion();
        this.add_controller(this_motion_events);
        this_motion_events.enter.connect(() => {
            file_default_widget.visible = true;
        });
        this_motion_events.leave.connect(() => {
            if (file_default_widget.file_menu.popover != null && file_default_widget.file_menu.popover.visible) return;

            file_default_widget.visible = false;
        });

        this.append(overlay);
    }
}

}
