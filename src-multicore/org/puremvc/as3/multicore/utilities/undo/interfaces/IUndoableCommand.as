/*
 PureMVC AS3 Utility – Undo
 Copyright (c) 2008 Dragos Dascalita <dragos.dascalita@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.puremvc.as3.utilities.undo.interfaces
{
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.interfaces.INotifier;
	
	public interface IUndoableCommand extends ICommand, INotifier
	{
		function getNote():INotification;
		function undo():void;
		function redo():void;
		function executeCommand():void;
	}
}