import React, { useState } from 'react';
import './App.css';
import { ethers } from "ethers";
import SuppartToken from "./contracts/SuppartToken.json";
import { Button, Alert } from 'react-bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';

// Needs to change to reflect current SuppartToken address
const contractAddress ='0x1715cFb28Dfb500cC985D8c285A8AcC05A9aEF8D';

let provider;
let signer;
let erc20;
let noProviderAbort = true;

// Ensures metamask or similar installed
if (typeof window.ethereum !== 'undefined' || (typeof window.web3 !== 'undefined')) {
	try{
		// Ethers.js set up, gets data from MetaMask and blockchain
		window.ethereum.enable().then(
			provider = new ethers.providers.Web3Provider(window.ethereum)
		);
		signer = provider.getSigner();
		erc20 = new ethers.Contract(contractAddress, SuppartToken.abi, signer);
		noProviderAbort = false;
	} catch(e) {
		noProviderAbort = true;
	}
}

function App() {
	const [walAddress, setWalAddress] = useState('0x00');
	const [sartBal, setSartBal] = useState(0);
	const [ethBal, setEthBal] = useState(0);

  const [inputs, setInputs] = React.useState({
    buysart: "",
    buysartProject: ""
  });

	const [coinSymbol, setCoinSymbol] = useState("Nil");
	const [transAmount, setTransAmount] = useState('0');
  //const [projectName, setProjectName] = useState("Nil");
	const [pendingFrom, setPendingFrom] = useState('0x00');
	const [pendingTo, setPendingTo] = useState('0x00');
	const [pendingAmount, setPendingAmount] = useState('0');
	const [isPending, setIsPending] = useState(false);
	const [errMsg, setErrMsg] = useState("Transaction failed!");
	const [isError, setIsError] = useState(false);

	// Aborts app if metamask etc not present
	if (noProviderAbort) {
		return (
			<div>
			<h1>Error</h1>
			<p><a href="https://metamask.io">Metamask</a> or equivalent required to access this page.</p>
			</div>
		);
	}

	// Notification to user that transaction sent to blockchain
	const PendingAlert = () => {
		if (!isPending) return null;
		return (
			<Alert key="pending" variant="info" 
			style={{position: 'absolute', top: 0}}>
			Blockchain event notification: transaction of {pendingAmount} 
			&#x39e; from <br />
			{pendingFrom} <br /> to <br /> {pendingTo}.
			</Alert>
		);
	};

	// Notification to user of blockchain error
	const ErrorAlert = () => {
		if (!isError) return null;
		return (
			<Alert key="error" variant="danger" 
			style={{position: 'absolute', top: 0}}>
			{errMsg}
			</Alert>
		);
	};

	// Sets current balance of SART for user
	signer.getAddress().then(response => {
		setWalAddress(response);
		return erc20.balanceOf(response);
	}).then(balance => {
		setSartBal(balance.toString())
	});

	// Sets current balance of Eth for user
	signer.getAddress().then(response => {
		return provider.getBalance(response);
	}).then(balance => {
		let formattedBalance = ethers.utils.formatUnits(balance, 18);
		setEthBal(formattedBalance.toString())
	});

	// Sets symbol of ERC20 token (i.e. PCT)
	async function getSymbol() {
		let symbol = await erc20.symbol();
		return symbol;
	}
	let symbol = getSymbol();
	symbol.then(x => setCoinSymbol(x.toString()));

	// Interacts with smart contract to buy PCT
	async function buySART() {
		// Converts integer as Eth to Wei,
		let amount = await ethers.utils.parseEther(inputs.buysart.toString());
    let project = inputs.buysartProject;

    console.log('inside buySART');
    console.log('amount: ' + amount);
    console.log('project: ' + project);

		try {
      await erc20.buyToken(transAmount, {value: amount});

			//await erc20.buyToken(transAmount, {value: amount}, {value: project});
			// Listens for event on blockchain
			await erc20.on("TokenBuyEvent", (from, to, amount) => {
				setPendingFrom(from.toString());
				setPendingTo(to.toString());
				setPendingAmount(amount.toString());
				setIsPending(true);
			})
		} catch(err) {
			if(typeof err.data !== 'undefined') {
				setErrMsg("Error: "+ err.data.message);
			} 
			setIsError(true);
		} 	
	}

	// Interacts with smart contract to sell PCT
	async function sellPCT() {
		try {
			await erc20.sellToken(transAmount);
			// Listens for event on blockchain
			await erc20.on("TokenSellEvent", (from, to, amount) => {
				setPendingFrom(from.toString());
				setPendingTo(to.toString());
				setPendingAmount(amount.toString());
				setIsPending(true);
			})
		} catch(err) {
			if(typeof err.data !== 'undefined') {
				setErrMsg("Error: "+ err.data.message);
			} 
			setIsError(true);
		} 
	}

	// Sets state for value to be transacted
	// Clears extant alerts
	function valueChange(value) {

    console.log('called valueChange: ' + value);

		setTransAmount(value);
		setIsPending(false);
		setIsError(false);
	}

  function handleChange(evt) {
    const value = evt.target.value;
    const name = evt.target.name;

    console.log(value);
    console.log(name);

    if(name === 'buysart')
    {
      setTransAmount(value);
    }

    setInputs({
      ...inputs,
      [evt.target.name]: value
    });
  }

	// Handles user buy form submit
	const handleBuySubmit = (e: React.FormEvent) => {
		e.preventDefault();
		valueChange(e.target.buysart.value);
		buySART();
	};

	// Handles user sell form submit
	const handleSellSubmit = (e: React.FormEvent) => {
		e.preventDefault();
		valueChange(e.target.sellpct.value);
		sellPCT();
	};

	return (
		<div className="App">
		<header className="App-header">

		<ErrorAlert />
		<PendingAlert />

		<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Ethereum-icon-purple.svg/512px-Ethereum-icon-purple.svg.png" className="App-logo" alt="Ethereum logo" />
    <img src="/images/Suppart.gif" className="App-logo-token" alt="Suppart logo" width="500" height="300" />

		<h2>{coinSymbol}</h2>

		<p>
		User Wallet address: {walAddress}<br/>
		Eth held: {ethBal}<br />
		SART held: {sartBal}<br />
		</p>

		<form onSubmit={handleBuySubmit}>
		<p>
		<label htmlFor="buysart">SART to buy:</label>
		<input type="number" step="1" min="0" id="buysart" name="buysart" onChange={handleChange} required style={{margin:'12px'}}/>	
    <label htmlFor="buysartProject">Project Name:</label>
    <input type="text" step="2" id="buysartProject" name="buysartProject" onChange={handleChange} required style={{margin:'12px'}}/>
		<Button type="submit" >Buy SART</Button>
		</p>
		</form>

		<form onSubmit={handleSellSubmit}>
		<p>
		<label htmlFor="sellpct">SART to sell:</label>
		<input type="number" step="1" min="0" id="sellpct" 
		name="sellpct" onChange={e => valueChange(e.target.value)} required 
		style={{margin:'12px'}}/>	
		<Button type="submit" >Sell PCT</Button>
		</p>
		</form>

		<a  title="GitR0n1n / CC BY-SA (https://creativecommons.org/licenses/by-sa/4.0)" href="https://commons.wikimedia.org/wiki/File:Ethereum-icon-purple.svg">
		<span style={{fontSize:'12px',color:'grey'}}>
		Ethereum logo by GitRon1n
		</span></a>
		</header>
		</div>
	);
}

export default App;