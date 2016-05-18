from colab_gitlab import models as gitlab
from colab_noosfero import models as noosfero
from colab.super_archives import models as mailman
from django.db import models


class CommunityAssociations(models.Model):
    community = models.ForeignKey(noosfero.NoosferoCommunity, default=1)
    group = models.ForeignKey(gitlab.GitlabGroup, default=1)
    mail_list = models.ForeignKey(mailman.MailingList, default=1)

    def __unicode__(self):
        return u'Social: {} - Dev: {} - List: {}'.format(self.community.name,
                                                         self.group.name,
                                                         self.mail_list.name)
