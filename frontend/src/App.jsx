import { useState, useEffect } from 'react'
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { ethers } from 'ethers'
import { Buffer } from 'buffer'
import Polling from '../Polling.json'
import { useAccount } from "wagmi";
import Button from 'react-bootstrap/Button';
import { Form } from 'react-bootstrap';

const contractAddress = import.meta.env.VITE_CONTRACT_ADDRESS

function App() {
  useEffect(() => {
    fetchPolls()
  }, [])
  const [submitting, setSubmittingState] = useState(false)
  const [viewState, setViewState] = useState('view-polls')
  const [posts, setPolls] = useState([])
  const [title, setTitle] = useState('')
  const [startDate, setStartDate] = useState('')
  const [endDate, setEndDate] = useState('')
  const [description, setDescription] = useState('')
  const { address } = useAccount();

  /* when the component loads, useEffect will call this function */
  async function fetchPolls() {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const contract = new ethers.Contract(contractAddress, Polling.abi, provider)
    let data = await contract.fetchPolls()
    /* once the data is returned from the network we map over it and */
    /* transform the data into a more readable format  */
    data = data.map(d => ({
      description: d['description'],
      title: d['title'],
      published: d['published'],
      id: d['id'].toString(),
      startDate: new Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit',day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit'}).format(d['startDate']),
      endDate: new Intl.DateTimeFormat('en-US', {year: 'numeric', month: '2-digit',day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit'}).format(d['endDate']),
    }))

    setPolls(data)
  }

  async function createPoll() {
    //const added = await client.add(description)
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const contract = new ethers.Contract(contractAddress, Polling.abi, signer)
    //const tx = await contract.createPoll(title, added.path, new Date(startDate).getTime(), new Date(endDate).getTime())
    const tx = await contract.createPoll(title, description, new Date(startDate).getTime(), new Date(endDate).getTime())
    setSubmittingState(true)
    await tx.wait()
    setSubmittingState(false)
    setViewState('view-polls')
  }

  function toggleView(currentState) {
    let value = 'view-polls';
    if (currentState === 'view-polls') {
      value = 'create-poll'
    } 
    setViewState(value)
    if (value === 'view-polls') {
      fetchPolls()
    }
  }
  
  return (
    <div className="outer-container">

      
      <div className="inner-container">
      <div className="d-flex justify-content-between flex-row">
        <h3 className="title">Celestia Snapshot</h3>
        <div className="button-container">
        <ConnectButton />
        </div>
      </div>
      
      

      {!address ? (<div>
        <h3>Getting Started</h3>
      <p>First, you will need to connect your Ethereum wallet to Ethermint to display the posts from the smart contract and make posts.</p>
      </div> ) : null}
      


      {address ? (
      <div className="button-container">
        <Button className="btn btn-primary"  onClick={() => toggleView(viewState)}>{ viewState === 'view-polls' ? 'Create Poll' : 'View Polls'}</Button>
      </div>
      ) : null}
      {
        viewState === 'view-polls' && address && (
          <div className="d-flex justify-content-between flex-row p-2">
            <div className="post-container">
            <h3>Current Polls</h3>
            <p className="small">All polls are retrieved from the DA layer (i.e. Celestia) via smart contracts running on an Ethermint network.</p>
            {
              posts.map((post, index) => (
                <div className="border pt-2 px-4 pb-4 mb-4" key={index}>
                  <h4 className="mt-2">{post.title}</h4>
                  <span className="badge bg-success mb-2">open</span>
                  <div>{post.description}</div>
                  <div className="pt-3">
                    <p className="m-0 text-sm-left"><span className="font-weight-bold">Start Date:</span> {post.startDate}</p>
                    <p className="m-0 text-sm-left"><span className="font-weight-bold">End Date:</span> {post.endDate}</p>
                  </div>
                  
                </div>
              ))
            }
          </div>
          </div>
        )
      }
      {
        viewState === 'create-poll' && (
          <div className="post-container">
              <h3>Create a New Poll</h3>
              <p className="small">Polls saved through this interaced are posted to Celestia's Data Availability layer.</p>
              <input
                placeholder='Poll Title'
                onChange={e => setTitle(e.target.value)}
              />
              <textarea
                placeholder='Description of your Poll'
                onChange={e => setDescription(e.target.value)}
              />
              <Form.Group controlId="startDate">
                  <Form.Control 
                    type="date" 
                    name="startDate" 
                    placeholder="Poll Start Date" 
                    onChange={e => setStartDate(e.target.value)} 
                    />
              </Form.Group>

              <Form.Group controlId="endDate">
                  <Form.Control 
                    type="date" 
                    name="endDate" 
                    placeholder="Poll End Date" 
                    onChange={e => setEndDate(e.target.value)} 
                    />
              </Form.Group>
              { submitting && (
                <div className="spinner-border" role="status">
                  <span className="sr-only">Saving</span>
                </div>)
              }
              <Button className="btn btn-success mt-3" onClick={createPoll}>Save Poll</Button>
          </div>
        )
      }
      </div>
    </div>
  )
}


export default App