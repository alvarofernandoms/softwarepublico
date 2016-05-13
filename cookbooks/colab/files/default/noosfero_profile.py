from colab.widgets.widget_manager import WidgetManager

from colab_noosfero.widgets.profile.profile import NoosferoProfileWidget

WidgetManager.register_widget('profile', NoosferoProfileWidget())
