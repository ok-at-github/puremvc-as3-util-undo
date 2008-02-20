/*
 PureMVC AS3 Utility – Undo
 Copyright (c) 2008 Dragos Dascalita <dragos.dascalita@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */

package org.puremvc.as3.utilities.controller
{
	import org.puremvc.as3.utilities.interfaces.IUndoableCommand;
	import org.puremvc.as3.utilities.model.CommandsHistoryProxy;
	import org.puremvc.as3.utilities.model.enum.UndoableCommandTypeEnum;
	import org.puremvc.interfaces.ICommand;
	import org.puremvc.interfaces.INotification;
	import org.puremvc.patterns.command.SimpleCommand;
	
	/**
	 * The base class for any undoable command.
	 * Any other classes that needs to be undo/redo enabled must extend it.
	 * 
	 * @author dragos
	 * 
	 */
	public class UndoableCommandBase extends SimpleCommand implements IUndoableCommand
	{
		/**
		 * Holds a rederence to note patameter, recieved from the <code>execute</code> method. 
		 */
		protected var _note:INotification;
		
		private var undoCmdClass:Class;
		
		/**
		 * Saves the command into the CommandHistoryProxy class 
		 * ( if <code>note.getType() == UndoableCommandEnum.RECORDABLE_COMMAND</code> )
		 * and calls the <code>executeCommand</code> method.
		 * 
		 * @param note The Notification instance
		 */
		override public function execute(note:INotification):void
		{
			_note = note;
			
			executeCommand();
			
			if ( note.getType() == UndoableCommandTypeEnum.RECORDABLE_COMMAND )
			{
				var historyProxy:CommandsHistoryProxy = facade.retrieveProxy( CommandsHistoryProxy.NAME ) as CommandsHistoryProxy;
				historyProxy.putCommand( this );
			}
		}
		
		/**
		 * Registers the undo command 
		 * @param cmdClass The class to be executed on undo
		 */
		public function registerUndoCommand( cmdClass:Class ):void
		{
			undoCmdClass = cmdClass;
		} 
		
		/**
		 * Returns the notification sent to this command 
		 * @return The notification
		 * 
		 */
		public function getNote():INotification
		{
			return _note;
		}
		
		/**
		 * This method must be overriden in the super class.
		 * Place here the code for the command to execute. 
		 */
		public function executeCommand():void
		{
			throw new Error("The undoable command does not have 'executeCommand' method implemented.");
		}
		
		/**
		 * Calls <code>executeCommand</code> 
		 */
		public function redo():void
		{
			executeCommand();
		}
		
		/**
		 * Calls the undo command setting its note type to 
		 * <code>UndoableCommandTypeEnum.NON_RECORDABLE_COMMAND</code> so that it won't get recorded into the history
		 * since it is already in the history
		 */
		public function undo():void
		{
			if ( undoCmdClass == null )
				throw new Error("Undo command not set. Could not undo. Use 'registerUndoCommand' to register an undo command");
			
			/** The type of the notification is used as a flag, 
			 * indicating wheather to save the command into the history, or not.
			 * The undo command, shold not be recorded into the history, 
			 * and its notification type is set to <code>UndoableCommandEnum.NON_RECORDABLE_COMMAND</code> 
			**/
			var oldType:String = _note.getType();
			_note.setType( UndoableCommandTypeEnum.NON_RECORDABLE_COMMAND );
			
			try
			{
				var commandInstance : ICommand = new undoCmdClass();
				commandInstance.execute( _note );
			}
			catch ( err:Error )
			{
				trace("Could not call undo on " + this + ". " + err.getStackTrace() );
			}
			
			_note.setType( oldType );
		}
	}
}