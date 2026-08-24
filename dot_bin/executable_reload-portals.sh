#!/bin/bash
# Restart XDG desktop portals

# Stop all portal services
systemctl --user stop xdg-desktop-portal.service
systemctl --user stop xdg-desktop-portal-gnome.service
systemctl --user stop xdg-desktop-portal-gtk.service
systemctl --user stop xdg-desktop-portal-hyprland.service
systemctl --user stop xdg-desktop-portal-wlr.service


# Kill any lingering portal processes
killall -q xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-desktop-portal-wlr

sleep 1

# Restart only the ones we need
systemctl --user start xdg-desktop-portal-gnome.service
systemctl --user start xdg-desktop-portal-gtk.service
systemctl --user start xdg-desktop-portal.service

echo "Portals restarted."
