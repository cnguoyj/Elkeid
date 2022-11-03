K_I_PATH		:= .
ifneq ($(wildcard /usr/src/kernels/$(KERNEL_HEAD)/include/.),)
K_I_PATH		+= /usr/src/kernels/$(KERNEL_HEAD)/include
endif
ifneq ($(wildcard /lib/modules/$(KERNEL_HEAD)/source/include/.),)
K_I_PATH		+= /lib/modules/$(KERNEL_HEAD)/source/include
endif
ifneq ($(wildcard /lib/modules/$(KERNEL_HEAD)/build/include/.),)
K_I_PATH		+= /lib/modules/$(KERNEL_HEAD)/build/include
endif

KMOD_FILES := $(shell find -L $(K_I_PATH) -path "*/linux/module.h") /dev/null
KMOD_CORE_LAYOUT := $(shell sh -c "grep -s module_core\; $(KMOD_FILES)")
ifeq ($(KMOD_CORE_LAYOUT),)
ccflags-y += -D KMOD_CORE_LAYOUT
endif

KGID_CRED_FILES := $(shell find -L $(K_I_PATH) -path "*/linux/cred.h") /dev/null
KGID_XIDS_FILES := $(shell find -L $(K_I_PATH) -path "*/linux/uidgid.h") /dev/null
KGID_STRUCT_CHECK := $(shell sh -c "grep -s fsgid\; $(KGID_CRED_FILES) | grep kgid_t")
ifneq ($(KGID_STRUCT_CHECK),)
ccflags-y += -D KGID_STRUCT_CHECK
KGID_CONFIG_CHECK := $(shell sh -c "grep -s CONFIG_UIDGID_STRICT_TYPE_CHECKS $(KGID_XIDS_FILES)")
ifneq ($(KGID_CONFIG_CHECK),)
ccflags-y += -D KGID_CONFIG_CHECK
endif
endif

IPV6_FILES := $(shell find -L $(K_I_PATH) -path \*/net/sock.h) /dev/null
IPV6_SUPPORT := $(shell sh -c "grep -s skc_v6_daddr\; $(IPV6_FILES)")
ifneq ($(IPV6_SUPPORT),)
ccflags-y += -D IPV6_SUPPORT
endif

UACCESS_FILES := $(shell find -L $(K_I_PATH) -path \*/asm-generic/uaccess.h) /dev/null
UACCESS_SUPPORT := $(shell sh -c "grep -sE define[[:space:]]\+access_ok $(UACCESS_FILES) | grep type")
ifneq ($(UACCESS_SUPPORT),)
ccflags-y += -D UACCESS_TYPE_SUPPORT
endif

TRACE_EVENTS_HEADERS	:= $(shell find -L $(K_I_PATH) -path \*/linux/trace_events.h)
ifneq ($(TRACE_EVENTS_HEADERS),)
ccflags-y += -D SMITH_TRACE_EVENTS
endif

TRACE_SEQ_FILES := $(shell find -L $(K_I_PATH) -path \*/linux/trace_seq.h) /dev/null
TRACE_SEQ_SEQ := $(shell sh -c "grep -sE struct[[:space:]]\+seq_buf[[:space:]]\+seq\; $(TRACE_SEQ_FILES)")
ifneq ($(TRACE_SEQ_SEQ),)
ccflags-y += -D SMITH_TRACE_SEQ
endif

PROCFS_H_FILES := $(shell find -L $(K_I_PATH) -path "*/linux/proc_fs.h") /dev/null
PROCFS_PDE_DATA := $(shell sh -c "grep -s pde_data $(PROCFS_H_FILES)")
ifneq ($(PROCFS_PDE_DATA),)
ccflags-y += -D SMITH_PROCFS_PDE_DATA
endif

PROCNS_H_FILES := $(shell find -L $(K_I_PATH) -path "*/linux/proc_ns.h") /dev/null
MNTNS_OPS_PROCFS := $(shell sh -c "grep -s mntns_operations $(PROCFS_H_FILES)")
MNTNS_OPS_PROCNS := $(shell sh -c "grep -s mntns_operations $(PROCNS_H_FILES)")
ifeq ($(MNTNS_OPS_PROCFS),)
ifeq ($(MNTNS_OPS_PROCNS),)
ccflags-y += -D SMITH_HAVE_NO_MNTNS_OPS
endif
else
ccflags-y += -D SMITH_HAVE_MNTNS_PROCFS
endif
MNTNS_OPS_INUM := $(shell sh -c "grep -s \(\[\*\]inum\) $(PROCFS_H_FILES) $(PROCNS_H_FILES)")
ifneq ($(MNTNS_OPS_INUM),)
ccflags-y += -D SMITH_HAVE_MNTNS_OPS_INUM
endif

USER_MSGHDR_FILES := $(shell find -L $(K_I_PATH) -path \*/linux/socket.h) /dev/null
USER_MSGHDR_STRUT := $(shell sh -c "grep -sE struct[[:space:]]\+user_msghdr[[:space:]]\+\{ $(USER_MSGHDR_FILES)")
ifeq ($(USER_MSGHDR_STRUT),)
ccflags-y += -D USER_MSGHDR_SUPPORT
endif