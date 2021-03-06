# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    def match_communities_mailinglists(apps, schema_editor):
        NoosferoCommunity = apps.get_model(
            "colab_noosfero", "NoosferoCommunity"
        )
        MailingList = apps.get_model("super_archives", "MailingList")
        Associations = apps.get_model("colab_spb", "CommunityAssociations")

        for community in NoosferoCommunity.objects.all():
            try:
                maillist = MailingList.objects.get(
                    name__iexact=community.identifier
                )

                association = Associations.objects.get_or_create(
                    mail_list=maillist,
                    community=community
                )
            except MailingList.DoesNotExist:
                continue

    dependencies = [
        ('colab_spb', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(match_communities_mailinglists)
    ]
