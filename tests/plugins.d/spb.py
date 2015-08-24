from django.utils.translation import ugettext_lazy as _                          
from colab.plugins.utils.menu import colab_url_factory                           
                                                                                 
name = "colab_spb"
verbose_name = "SPB Plugin"
urls = {                                                                         
         "include":"colab_spb.urls",                                             
         "prefix": '^spb/',                                                      
         "namespace":"colab_spb"                                                 
       }                                                                         
                                                                                 
url = colab_url_factory('colab_spb')  
