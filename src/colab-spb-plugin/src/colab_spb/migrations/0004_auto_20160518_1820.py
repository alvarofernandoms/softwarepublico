# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('colab_spb', '0003_auto_20160229_1804'),
    ]

    operations = [
        migrations.AlterField(
            model_name='communityassociations',
            name='community',
            field=models.ForeignKey(default=1, to='colab_noosfero.NoosferoCommunity'),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='communityassociations',
            name='group',
            field=models.ForeignKey(default=1, to='colab_gitlab.GitlabGroup'),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='communityassociations',
            name='mail_list',
            field=models.ForeignKey(default=1, to='super_archives.MailingList'),
            preserve_default=True,
        ),
    ]
