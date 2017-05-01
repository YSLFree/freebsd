#!/bin/sh

#
# Copyright (c) 2008 Peter Holm <pho@FreeBSD.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD$
#

# Caused panic: ffs_truncate3
# The problem is caused by a full FS with Soft-updates disabled.

[ `id -u ` -ne 0 ] && echo "Must be root!" && exit 1

. ../default.cfg

mount | grep "$mntpoint" | grep md${mdstart}$part > /dev/null && umount $mntpoint
[ -c /dev/md$mdstart ] &&  mdconfig -d -u $mdstart

mdconfig -a -t swap -s 2m -u $mdstart
bsdlabel -w md$mdstart auto
newfs md${mdstart}$part > /dev/null
mount /dev/md${mdstart}$part $mntpoint

export RUNDIR=$mntpoint/stressX
export KBLOCKS=30000		# Exaggerate disk capacity
export INODES=8000

for i in `jot 20`; do
   (cd ../testcases/rw;./rw -t 2m -i 20 > /dev/null 2>&1)
done

while mount | grep -q $mntpoint; do
	umount $([ $((`date '+%s'` % 2)) -eq 0 ] &&
	    echo "-f" || echo "") $mntpoint > /dev/null 2>&1
done

mdconfig -d -u $mdstart
exit 0
