from django import template

from colab_spb.models import CommunityAssociations

register = template.Library()

@register.simple_tag
def get_community(mailinglist):
    ml = mailinglist
    community = ""

    try:
        community_association = CommunityAssociations.objects.get(mail_list=ml)
        community = community_association.community.identifier
    except CommunityAssociations.DoesNotExist:
        community = "software"

    return community

@register.simple_tag
def get_software_community(gitlab_group):
    group = gitlab_group
    community = ""

    try:
        community_association = CommunityAssociations.objects.get(group=group)
        community = community_association.community.identifier
    except CommunityAssociations.DoesNotExist:
        community = ""

    return community

