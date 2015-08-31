# -*- coding: utf-8 -*-
from django.shortcuts import render
from django.http import HttpResponse
from colab.super_archives.models import MailingList, Thread
from colab.accounts.utils import mailman
from colab.accounts.models import User


def get_list(request):
    list_name = request.GET.get('list_name', None)
    MAX = request.GET.get('MAX', 7)

    if not MAX:
        MAX = 7

    context = {}

    all_privates = {}
    private_mailinglist = MailingList.objects.filter(is_private=True)
    for mailinglist in private_mailinglist:
        all_privates[mailinglist.name] = True

    context['lists'] = []

    lists_for_user = []
    if request.user.is_authenticated():
        user = User.objects.get(username=request.user)
        lists_for_user = mailman.get_user_mailinglists(user)

    for list_ in MailingList.objects.filter(name__iexact=list_name):
        if list_.name not in all_privates or list_.name in lists_for_user:
            context['lists'].append((
                list_.name,
                mailman.get_list_description(list_.name),
                list_.thread_set.filter(spam=False).order_by(
                    '-latest_message__received_time'
                )[:MAX],
                [t.latest_message for t in Thread.highest_score.filter(
                    mailinglist__name=list_.name)[:MAX]],
                len(mailman.list_users(list_.name)),
            ))

    if len(context['lists']) == 0:
        message = ("Não foi possível encontrada lista de discussão"
                   " associada a está comunidade, para mais"
                   " detalhes contate o administrador.")
        return HttpResponse(message, status=404)

    return render(request, "discussion.html", context)
