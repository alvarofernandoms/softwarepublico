from colab.settings import *  # noqa

SOCIAL_NETWORK_ENABLED = True
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'

LOGGING = {
    'version': 1,

    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'logging.NullHandler',
        },
    },

    'loggers': {
        'colab.mailman': {
            'handlers': ['null'],
            'propagate': False,
        },
        'haystack': {
            'handlers': ['null'],
            'propagate': False,
        },
        'pysolr': {
            'handlers': ['null'],
            'propagate': False,
        },
    },
}

HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'haystack.backends.whoosh_backend.WhooshEngine',
        'PATH': os.path.join(BASE_DIR, 'whoosh_index'),
    }
}

