using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CallPlugInMethods : MonoBehaviour
{

	[SerializeField] private Text text;
	private int notZero = 1;

	public void PushButton()
	{
		text.text = "" + notZero++;
	}
}
